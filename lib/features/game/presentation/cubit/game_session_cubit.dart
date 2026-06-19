import 'dart:async';

import 'package:deadbounce_flutter_app/core/audio/music_manager.dart';
import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/sync/sync_worker.dart';
import '../../../../core/util/calendar_day.dart';
import '../../../achievements/domain/repositories/achievements_repository.dart';
import '../../../meta/domain/meta_catalog.dart';
import '../../../meta/domain/meta_loadout.dart';
import '../../../meta/domain/repositories/meta_repository.dart';
import '../../../runs/domain/entities/run_result.dart';
import '../../../runs/domain/repositories/runs_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../engine/arena/arena_catalog.dart';
import '../../engine/challenge/challenge_catalog.dart';
import '../../engine/challenge/challenge_config.dart';
import '../../engine/game_rng.dart';
import '../../engine/upgrades/upgrade_card.dart';
import '../game/components/deadbounce_game.dart';
import '../game/game_feel.dart';
import '../game/game_session_gateway.dart';
import '../game/hud_model.dart';
import '../game/tournament_run_context.dart';
import '../game/systems/flame_audio_sound_manager.dart';
import '../game/systems/haptics_service.dart';
import '../game/systems/sound_manager.dart';

part 'game_session_state.dart';

/// Owns the run lifecycle: builds the game, brokers wave-clear upgrade
/// picks, and persists the result through the data layer at run end.
/// The only thing in the game feature that touches repositories.
class GameSessionCubit extends Cubit<GameSessionState>
    implements GameSessionGateway {
  GameSessionCubit({
    required this._runsRepository,
    required this._achievementsRepository,
    required this._settingsRepository,
    required this._syncWorker,
    required this._metaRepository,
    this.dailyChallenge = false,
    this.tournamentContext,
    Uuid? uuid,
  })  : _uuid = uuid ?? const Uuid(),
        super(const SessionIdle());

  final RunsRepository _runsRepository;
  final AchievementsRepository _achievementsRepository;
  final SettingsRepository _settingsRepository;
  final SyncWorker _syncWorker;
  final MetaRepository _metaRepository;
  final bool dailyChallenge;

  /// Set when this session is a tournament run (mutually exclusive with
  /// [dailyChallenge]). Carries the seed + ruleset to play offline.
  final TournamentRunContext? tournamentContext;
  final Uuid _uuid;

  bool get _isTournament => tournamentContext != null;

  final HudModel hud = HudModel();
  DeadbounceGame? game;
  SoundManager? _sound;
  int? _challengeSeed;
  String? _challengeDate;
  String? _tournamentId;
  int _previousBestScore = 0;

  /// Completes early when the player taps to skip the death beat.
  Completer<void>? _skipBeat;

  /// How long the death beat holds before the results appear.
  static const Duration _beatDuration = Duration(milliseconds: 1400);

  Future<void> startRun() async {
    final best = await _runsRepository.bestRun();
    _previousBestScore = best?.score ?? 0;

    final GameRng rng;
    ChallengeConfig? challengeConfig;
    if (_isTournament) {
      _tournamentId = tournamentContext!.tournamentId;
      challengeConfig = tournamentContext!.config;
      rng = GameRng(tournamentContext!.seed);
    } else if (dailyChallenge) {
      final today = DateTime.now().toUtc();
      _challengeSeed = GameRng.dailySeed(today);
      _challengeDate = CalendarDay.utc(today);
      challengeConfig =
          ChallengeCatalog.forUtcDate(_challengeDate!, _challengeSeed!).config;
      rng = GameRng(_challengeSeed!);
    } else {
      rng = GameRng(DateTime.now().microsecondsSinceEpoch);
    }

    final arena = rng.fork('arena').pick(ArenaCatalog.all);
    AppLogger.talker.info(
      '[game] startRun dailyChallenge=$dailyChallenge '
      'tournament=${_tournamentId ?? '-'} arena=${arena.id}',
    );
    final settings = await _settingsRepository.load();

    MusicManager.instance.enabled = settings.musicEnabled;
    MusicManager.instance.play(MusicTrack.combat);

    final sound = FlameAudioSoundManager(enabled: settings.soundEnabled);
    _sound = sound;

    // Permanent Gunsmith perks apply to normal runs only — daily challenges
    // AND tournaments stay fair and identical for everyone.
    final loadout = (dailyChallenge || _isTournament)
        ? MetaLoadout.empty
        : _buildLoadout(await _metaRepository.ownedLevels());

    game = DeadbounceGame(
      gateway: this,
      hud: hud,
      arenaDef: arena,
      runRng: rng,
      sound: sound,
      hapticsService: HapticsService(enabled: settings.hapticsEnabled),
      isDailyChallenge: dailyChallenge,
      challengeDate: _challengeDate,
      challenge: challengeConfig,
      metaLoadout: loadout,
      gameFeel: GameFeel(
        screenShake: settings.screenShakeEnabled,
        hitStop: settings.hitStopEnabled,
        aimGuide: settings.aimGuideEnabled,
        combatText: settings.combatTextEnabled,
        particleBudget: settings.particleQuality.budget,
      ),
    );

    // Warm the audio during the pre-game beat so the arena-flavored
    // loading scene reads as intentional, not a stutter, and the first
    // shot isn't silent.
    await Future.wait([
      sound.preload(),
      Future<void>.delayed(const Duration(milliseconds: 1300)),
    ]);
    if (isClosed) return;
    emit(const SessionPlaying());
  }

  /// Maps owned perk levels into the run's [MetaLoadout]. Most perks reuse
  /// existing upgrade-card modifiers (so they fold through the normal
  /// pipeline); Iron Resolve and Second Wind are handled by the game.
  MetaLoadout _buildLoadout(Map<String, int> owned) {
    final cards = <String, int>{};
    void mapToCard(String perkId, String cardId) {
      final level = owned[perkId] ?? 0;
      if (level > 0) cards[cardId] = level;
    }

    mapToCard(MetaCatalog.reinforcedHeart, 'heart_container');
    mapToCard(MetaCatalog.quickHands, 'quickdraw');
    mapToCard(MetaCatalog.keenEye, 'longer_sight');
    mapToCard(MetaCatalog.luckyStrike, 'coin_magnet');

    return MetaLoadout(
      permanentCards: cards,
      invulnBonus: 0.25 * (owned[MetaCatalog.ironResolve] ?? 0),
      grantFreeCard: (owned[MetaCatalog.secondWind] ?? 0) > 0,
    );
  }

  void pause() {
    if (state is! SessionPlaying) return;
    game?.pauseEngine();
    emit(const SessionPaused());
  }

  void resume() {
    if (state is! SessionPaused) return;
    game?.resumeEngine();
    emit(const SessionPlaying());
  }

  void selectUpgrade(UpgradeCard card) {
    if (state is! SessionUpgradePicking) return;
    game?.applyUpgrade(card);
    emit(const SessionPlaying());
  }

  // ---- GameSessionGateway (called by the game) ----

  @override
  void onWaveCleared(int wave, List<UpgradeCard> choices) {
    emit(SessionUpgradePicking(wave, choices));
  }

  /// Cuts the death beat short — straight to the results.
  void skipEnding() {
    if (state is! SessionRunEnding) return;
    final c = _skipBeat;
    if (c != null && !c.isCompleted) c.complete();
  }

  @override
  Future<void> onRunEnded(RunStatsSnapshot stats) async {
    final result = RunResult(
      id: _uuid.v4(),
      score: stats.score,
      waveReached: stats.waveReached,
      kills: stats.kills,
      bestChain: stats.bestChain,
      maxBounceKill: stats.maxBounceKill,
      duration: Duration(milliseconds: (stats.durationSeconds * 1000).round()),
      coinsEarned: stats.coinsEarned,
      arenaId: game?.arenaDef.id ?? 'unknown',
      upgradesPicked: stats.upgradesPicked,
      endedAt: DateTime.now().toUtc(),
      enemyKills: stats.enemyKills,
      isDailyChallenge: dailyChallenge,
      challengeDate: _challengeDate,
      challengeSeed: _challengeSeed,
      tournamentId: _tournamentId,
    );

    AppLogger.talker.info(
      '[game] run ended score=${stats.score} wave=${stats.waveReached} '
      'cause=${stats.causeOfDeath ?? 'unknown'}',
    );

    // 1) The death beat: tell the player what happened, hold for a moment.
    final death = _describeDeath(stats);
    _skipBeat = Completer<void>();
    emit(SessionRunEnding(
      headline: death.$1,
      detail: death.$2,
      wave: stats.waveReached,
    ));

    // 2) Persist + evaluate achievements in parallel with the beat (Drift
    // first; the outbox carries it to the backend). Names captured for the
    // results screen.
    var unlockedNames = const <String>[];
    final work = () async {
      await _runsRepository.recordCompletedRun(result);
      final unlocked = await _achievementsRepository.evaluateRun(
        RunAchievementInput(
          score: stats.score,
          wave: stats.waveReached,
          bestChain: stats.bestChain,
          maxBounceKill: stats.maxBounceKill,
          upgradesPicked: stats.upgradesPicked.length,
          hitsTaken: stats.hitsTaken,
          isDailyChallenge: dailyChallenge,
        ),
      );
      AppLogger.talker.info('[game] achievements unlocked: ${unlocked.length}');
      unlockedNames = unlocked.map((a) => a.name).toList();
      _syncWorker.requestSync();
    }();

    await Future.wait([
      work,
      Future.any([
        Future<void>.delayed(_beatDuration),
        _skipBeat!.future,
      ]),
    ]);

    // 3) Results.
    if (isClosed) return;
    emit(SessionRunOver(
      result,
      isNewBestScore: result.score > _previousBestScore && result.score > 0,
      unlockedAchievements: unlockedNames,
    ));
  }

  /// (headline, detail) for the death beat, in the Deadbounce voice.
  (String, String) _describeDeath(RunStatsSnapshot stats) {
    if (_isTournament) {
      return ('TOURNAMENT RUN OVER', 'Your run is locked in.');
    }
    if (dailyChallenge) {
      return ('CHALLENGE OVER', 'Your daily run ends here.');
    }
    final detail = switch (stats.causeOfDeath) {
      'drifter' || 'smallDrifter' => 'A Drifter drifted right into you.',
      'charger' => 'A Charger ran you down.',
      'splitter' => 'A Splitter swarmed you.',
      'turret' => "A Turret's shot found you.",
      'warden' => 'The Warden broke you.',
      _ => 'The arena claimed you.',
    };
    return ('YOU FELL', detail);
  }

  @override
  Future<void> close() {
    hud.dispose();
    _sound?.dispose();
    return super.close();
  }
}
