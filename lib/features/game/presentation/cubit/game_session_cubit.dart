import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/sync/sync_worker.dart';
import '../../../../core/util/calendar_day.dart';
import '../../../achievements/domain/repositories/achievements_repository.dart';
import '../../../runs/domain/entities/run_result.dart';
import '../../../runs/domain/repositories/runs_repository.dart';
import '../../engine/arena/arena_catalog.dart';
import '../../engine/challenge/challenge_catalog.dart';
import '../../engine/challenge/challenge_config.dart';
import '../../engine/game_rng.dart';
import '../../engine/upgrades/upgrade_card.dart';
import '../game/components/deadbounce_game.dart';
import '../game/game_session_gateway.dart';
import '../game/hud_model.dart';
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
    required this._syncWorker,
    this.dailyChallenge = false,
    Uuid? uuid,
  })  : _uuid = uuid ?? const Uuid(),
        super(const SessionIdle());

  final RunsRepository _runsRepository;
  final AchievementsRepository _achievementsRepository;
  final SyncWorker _syncWorker;
  final bool dailyChallenge;
  final Uuid _uuid;

  final HudModel hud = HudModel();
  DeadbounceGame? game;
  int? _challengeSeed;
  String? _challengeDate;
  int _previousBestScore = 0;

  Future<void> startRun() async {
    final best = await _runsRepository.bestRun();
    _previousBestScore = best?.score ?? 0;

    final GameRng rng;
    ChallengeConfig? challengeConfig;
    if (dailyChallenge) {
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

    game = DeadbounceGame(
      gateway: this,
      hud: hud,
      arenaDef: arena,
      runRng: rng,
      sound: NoOpSoundManager(),
      hapticsService: HapticsService(),
      isDailyChallenge: dailyChallenge,
      challengeDate: _challengeDate,
      challenge: challengeConfig,
    );

    // Brief pre-game beat so the arena-flavored loading scene reads as
    // intentional, not a stutter.
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    if (isClosed) return;
    emit(const SessionPlaying());
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
    );

    // Drift first, synchronously with the UI; the backend hears about it
    // whenever the outbox drains. Achievements evaluate AFTER the run is
    // recorded so they see the freshly-updated lifetime stats.
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
    _syncWorker.requestSync();

    emit(SessionRunOver(
      result,
      isNewBestScore:
          result.score > _previousBestScore && result.score > 0,
      unlockedAchievements: unlocked.map((a) => a.name).toList(),
    ));
  }

  @override
  Future<void> close() {
    hud.dispose();
    return super.close();
  }
}
