import 'dart:async';

import 'package:deadbounce_flutter_app/core/analytics/analytics.dart';
import 'package:deadbounce_flutter_app/core/audio/music_manager.dart';
import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/game_balance.dart';
import '../../../../core/sync/sync_worker.dart';
import '../../../../core/util/calendar_day.dart';
import '../../../achievements/domain/repositories/achievements_repository.dart';
import '../../../cosmetics/domain/repositories/cosmetics_repository.dart';
import '../../../economy/domain/entities/coin_transaction.dart';
import '../../../economy/domain/repositories/wallet_repository.dart';
import '../../../meta/domain/meta_catalog.dart';
import '../../../meta/domain/meta_loadout.dart';
import '../../../meta/domain/repositories/meta_repository.dart';
import '../../../runs/domain/entities/run_result.dart';
import '../../../runs/domain/repositories/runs_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../statistics/domain/repositories/statistics_repository.dart';
import '../../engine/arena/arena_catalog.dart';
import '../../engine/challenge/challenge_catalog.dart';
import '../../engine/challenge/challenge_config.dart';
import '../../engine/game_rng.dart';
import '../../engine/progression/unlock_catalog.dart';
import '../../engine/upgrades/upgrade_card.dart';
import '../../engine/upgrades/upgrade_catalog.dart';
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
    required this._cosmeticsRepository,
    required this._walletRepository,
    required this._statisticsRepository,
    this.dailyChallenge = false,
    this.tournamentContext,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid(),
       super(const SessionIdle());

  final RunsRepository _runsRepository;
  final AchievementsRepository _achievementsRepository;
  final SettingsRepository _settingsRepository;
  final SyncWorker _syncWorker;
  final MetaRepository _metaRepository;
  final CosmeticsRepository _cosmeticsRepository;
  final WalletRepository _walletRepository;
  final StatisticsRepository _statisticsRepository;
  final bool dailyChallenge;

  /// Set when this session is a tournament run (mutually exclusive with
  /// [dailyChallenge]). Carries the seed + ruleset to play offline.
  final TournamentRunContext? tournamentContext;
  final Uuid _uuid;

  bool get _isTournament => tournamentContext != null;

  /// Analytics slice. Normal runs are the only ones carrying perks, unlocks
  /// and coin sinks, so nearly every funnel needs splitting on this.
  String get _analyticsMode =>
      _isTournament ? 'tournament' : (dailyChallenge ? 'daily' : 'normal');

  final HudModel hud = HudModel();
  DeadbounceGame? game;
  SoundManager? _sound;
  int? _challengeSeed;
  String? _challengeDate;
  String? _tournamentId;
  int _previousBestScore = 0;

  /// Draft rerolls used this run — the coin cost escalates with each use.
  int _rerollsThisRun = 0;

  /// Reroll is a normal-run coin sink; seeded modes keep their draws pure.
  bool get _rerollEnabled => !dailyChallenge && !_isTournament;

  /// Completes early when the player taps to skip the death beat.
  Completer<void>? _skipBeat;

  /// How long the death beat holds before the results appear.
  static const Duration _beatDuration = Duration(milliseconds: 1400);

  Future<void> startRun() async {
    _rerollsThisRun = 0;
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
      challengeConfig = ChallengeCatalog.forUtcDate(
        _challengeDate!,
        _challengeSeed!,
      ).config;
      rng = GameRng(_challengeSeed!);
    } else {
      rng = GameRng(DateTime.now().microsecondsSinceEpoch);
    }

    // Play-gated unlocks apply to NORMAL runs only; daily challenges +
    // tournaments use the full catalog so they stay identical worldwide.
    Set<String>? unlockedCardIds;
    var arenaPool = ArenaCatalog.all;
    if (!dailyChallenge && !_isTournament) {
      final stats = await _statisticsRepository.getStatistics();
      final unlockStats = UnlockStats(
        bestWave: stats.bestWave,
        runsPlayed: stats.runsPlayed,
        lifetimeKills: stats.totalKills,
      );
      unlockedCardIds = UnlockCatalog.unlockedCardIds(
          UpgradeCatalog.all.map((c) => c.id), unlockStats);
      arenaPool =
          UnlockCatalog.unlockedArenas(ArenaCatalog.all, (a) => a.id, unlockStats);
    }

    final arena = rng.fork('arena').pick(arenaPool);
    AppLogger.talker.info(
      '[game] startRun dailyChallenge=$dailyChallenge '
      'tournament=${_tournamentId ?? '-'} arena=${arena.id} '
      'unlockedCards=${unlockedCardIds?.length ?? 'all'}',
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

    // Cosmetics are visual-only, so they're fair in every mode.
    final cosmetics = await _cosmeticsRepository.loadout();

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
      cosmetics: cosmetics,
      unlockedCardIds: unlockedCardIds,
      gameFeel: GameFeel(
        screenShake: settings.screenShakeEnabled,
        hitStop: settings.hitStopEnabled,
        aimGuide: settings.aimGuideEnabled,
        combatText: settings.combatTextEnabled,
        particleBudget: settings.particleQuality.budget,
      ),
    );

    // Warm the audio during the pre-game beat so the first shot isn't
    // silent. The delay floor only prevents a single-frame loading flash —
    // it must stay short: this gate is paid on EVERY run and retry, and a
    // long one taxes the "one more run" loop.
    await Future.wait([
      sound.preload(),
      Future<void>.delayed(const Duration(milliseconds: 350)),
    ]);
    if (isClosed) return;
    Analytics.runStart(mode: _analyticsMode, arenaId: arena.id);
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
      grantFreeRareCard: (owned[MetaCatalog.openingHand] ?? 0) > 0,
      chainWindowBonus: 0.15 * (owned[MetaCatalog.chainMemory] ?? 0),
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
    final s = state;
    if (s is! SessionUpgradePicking) return;
    Analytics.upgradePicked(
      cardId: card.id,
      rarity: card.rarity.name,
      wave: s.waveCleared,
    );
    game?.applyUpgrade(card);
    emit(const SessionPlaying());
  }

  // ---- GameSessionGateway (called by the game) ----

  @override
  void onWaveCleared(int wave, List<UpgradeCard> choices) {
    Analytics.waveCleared(mode: _analyticsMode, wave: wave);
    // Fire-and-forget: the engine is already paused, so the brief balance
    // fetch before the picker shows is invisible.
    _emitPicking(wave, choices);
  }

  Future<void> _emitPicking(int wave, List<UpgradeCard> choices) async {
    final cost = _rerollEnabled ? _rerollCost() : 0;
    final balance = cost > 0 ? await _walletRepository.getBalance() : 0;
    if (isClosed) return;
    emit(SessionUpgradePicking(wave, choices,
        rerollCost: cost, balance: balance));
  }

  int _rerollCost() {
    final e = GameBalance.I.economy;
    return e.draftRerollBaseCost + e.draftRerollCostStep * _rerollsThisRun;
  }

  /// Spends coins to redraw the current draft (the escalating coin sink).
  Future<void> rerollDraft() async {
    final s = state;
    if (s is! SessionUpgradePicking || !s.canReroll) return;
    await _walletRepository.addTransaction(
      amount: -s.rerollCost,
      reason: CoinReason.draftReroll,
    );
    Analytics.draftReroll(
      cost: s.rerollCost,
      rerollIndex: _rerollsThisRun,
      wave: s.waveCleared,
    );
    _rerollsThisRun++;
    final fresh = game?.rerollChoices() ?? s.choices;
    await _emitPicking(s.waveCleared, fresh);
  }

  @override
  void onOfferContinue(int wave) {
    // Only the game decides a continue is available (normal run, unused);
    // here we gate on affordability. Can't afford → let the run end.
    _offerContinue(wave);
  }

  Future<void> _offerContinue(int wave) async {
    // Priced by how many buy-backs this run has already had — the engine owns
    // the count, the balance table owns the ladder.
    final costs = GameBalance.I.economy.continueRunCosts;
    final used = game?.continuesUsed ?? 0;
    if (used >= costs.length) {
      game?.endRun();
      return;
    }
    final cost = costs[used];
    final balance = await _walletRepository.getBalance();
    if (isClosed) return;
    // Logged even when they can't afford it: "offered but unaffordable" is
    // exactly the population a rewarded-ad continue would convert in Phase 4.
    Analytics.continueOffered(
      wave: wave,
      cost: cost,
      canAfford: balance >= cost,
    );
    if (balance < cost) {
      game?.endRun();
      return;
    }
    emit(SessionAwaitingContinue(wave: wave, cost: cost, canAfford: true));
  }

  /// Buys the one-per-run continue: spend coins, revive, resume.
  Future<void> buyContinue() async {
    final s = state;
    if (s is! SessionAwaitingContinue || !s.canAfford) return;
    await _walletRepository.addTransaction(
      amount: -s.cost,
      reason: CoinReason.continueRun,
    );
    Analytics.continueBought(wave: s.wave, cost: s.cost);
    if (isClosed) return;
    game?.reviveForContinue();
    emit(const SessionPlaying());
  }

  /// Declines the continue — the run ends normally (the death beat follows).
  void declineContinue() {
    final s = state;
    if (s is! SessionAwaitingContinue) return;
    Analytics.continueDeclined(wave: s.wave);
    game?.endRun();
  }

  /// Cuts the death beat short — straight to the results.
  void skipEnding() {
    if (state is! SessionRunEnding) return;
    final c = _skipBeat;
    if (c != null && !c.isCompleted) c.complete();
  }

  bool _runRecorded = false;

  @override
  Future<void> onRunEnded(RunStatsSnapshot stats) async {
    // Idempotent: a double onRunEnded (engine + any future caller) can never
    // double-record the run / re-submit the score, regardless of game state.
    if (_runRecorded) return;
    _runRecorded = true;

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

    Analytics.runEnd(
      mode: _analyticsMode,
      wave: stats.waveReached,
      score: stats.score,
      kills: stats.kills,
      durationSeconds: stats.durationSeconds.round(),
      coinsEarned: stats.coinsEarned,
      causeOfDeath: stats.causeOfDeath,
    );

    // 1) The death beat: tell the player what happened, hold for a moment.
    final death = _describeDeath(stats);
    _skipBeat = Completer<void>();
    emit(
      SessionRunEnding(
        headline: death.$1,
        detail: death.$2,
        wave: stats.waveReached,
      ),
    );

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
      // Refresh the cohorting dimensions now that this run is folded in.
      // Runs inside the beat window, so it costs no visible time.
      final lifetime = await _statisticsRepository.getStatistics();
      Analytics.setPlayerProperties(
        bestWave: lifetime.bestWave,
        runsPlayed: lifetime.runsPlayed,
      );
      _syncWorker.requestSync();
    }();

    await Future.wait([
      work,
      Future.any([Future<void>.delayed(_beatDuration), _skipBeat!.future]),
    ]);

    // 3) Results.
    if (isClosed) return;
    emit(
      SessionRunOver(
        result,
        isNewBestScore: result.score > _previousBestScore && result.score > 0,
        unlockedAchievements: unlockedNames,
      ),
    );
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
      'powderkeg' => 'A Powderkeg blast caught you.',
      'sawbones' => 'A Sawbones patched them up and ran you down.',
      'ironhide' => 'An Ironhide bulled you over.',
      'mirror' => 'A Mirror cut you down.',
      'skitter' => 'A Skitter darted in before you could react.',
      'lancer' => "A Lancer's strafe ran you through.",
      _ => 'The arena claimed you.',
    };
    return ('YOU FELL', detail);
  }

  @override
  Future<void> close() {
    // Stop the Flame loop BEFORE disposing the HUD notifiers — otherwise one
    // more update() can push to disposed ValueNotifiers (asserts in debug,
    // notifies freed listeners in release).
    game?.pauseEngine();
    hud.dispose();
    _sound?.dispose();
    return super.close();
  }
}
