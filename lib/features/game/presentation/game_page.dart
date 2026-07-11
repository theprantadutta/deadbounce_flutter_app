import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/review/app_review_service.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/db_loading_scene.dart';
import 'cubit/game_session_cubit.dart';
import 'debug/tuning_panel.dart';
import 'game/components/deadbounce_game.dart';
import 'game/hud_model.dart';
import 'game/tournament_run_context.dart';
import 'overlays/continue_overlay.dart';
import 'overlays/hud_overlay.dart';
import 'overlays/pause_overlay.dart';
import 'overlays/run_ending_overlay.dart';
import 'overlays/run_results_overlay.dart';
import 'overlays/upgrade_picker_overlay.dart';

/// Hosts the arena. All chrome (HUD, pause, upgrade picker, results) is
/// normal Flutter widgets stacked over the GameWidget, driven by the
/// session cubit — the game pauses underneath the overlays.
class GamePage extends StatelessWidget {
  const GamePage({
    super.key,
    this.dailyChallenge = false,
    this.tournamentContext,
  });

  final bool dailyChallenge;
  final TournamentRunContext? tournamentContext;

  @override
  Widget build(BuildContext context) {
    final session = context.sessionDependencies;
    return BlocProvider(
      create: (_) => GameSessionCubit(
        runsRepository: session.runsRepository,
        achievementsRepository: session.achievementsRepository,
        settingsRepository: session.settingsRepository,
        syncWorker: session.syncWorker,
        metaRepository: session.metaRepository,
        cosmeticsRepository: session.cosmeticsRepository,
        walletRepository: session.walletRepository,
        statisticsRepository: session.statisticsRepository,
        dailyChallenge: dailyChallenge,
        tournamentContext: tournamentContext,
      )..startRun(),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatefulWidget {
  const _GameView();

  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> with WidgetsBindingObserver {
  /// One review prompt per game screen at most (guards rebuilds/re-emits).
  bool _reviewPromptRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// After a normal run ends, offer the native "rate this app" sheet — but only
  /// when the throttle allows it ([ReviewPromptStore]). Seeded/constrained modes
  /// (daily challenge, tournaments) are skipped so we ask on the core loop.
  Future<void> _maybePromptReview() async {
    if (_reviewPromptRequested) return;
    final cubit = context.read<GameSessionCubit>();
    if (cubit.dailyChallenge || cubit.tournamentContext != null) return;
    _reviewPromptRequested = true;
    final reviewService = context.read<AppReviewService>();
    final stats =
        await context.sessionDependencies.statisticsRepository.getStatistics();
    await reviewService.maybePromptReview(runsPlayed: stats.runsPlayed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Freeze the run when the app leaves the screen so enemies don't keep
    // advancing (and the player can't die) off-screen. pause() is a safe no-op
    // unless a wave is actually playing, and it raises the pause overlay so
    // resume is deliberate.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      context.read<GameSessionCubit>().pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameSessionCubit>();

    return Scaffold(
      body: BlocConsumer<GameSessionCubit, GameSessionState>(
        listener: (context, state) {
          if (state is SessionRunOver) _maybePromptReview();
        },
        builder: (context, state) {
          final game = cubit.game;
          if (state is SessionIdle || game == null) {
            return const DbLoadingScene(
              title: 'LOADING THE ARENA',
              subtitle: 'Chalk your hands, partner.',
              showLogo: false,
              tips: [
                'Drag to aim. Release to fire.',
                'Tap a side to dash and dodge.',
                'No damage until it bounces.',
                'Line up shots behind the walls.',
              ],
            );
          }

          return Stack(
            children: [
              Positioned.fill(child: GameWidget(game: game)),
              HudOverlay(hud: cubit.hud, onPause: cubit.pause),
              // Debug-only live tuning entry point. Compiled out of release.
              if (kDebugMode)
                Positioned(
                  left: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  child: SafeArea(
                    child: FloatingActionButton.small(
                      heroTag: 'tuning-panel',
                      backgroundColor: AppColors.ink800,
                      foregroundColor: AppColors.amber300,
                      onPressed: () => _openTuning(context, game, cubit.hud),
                      child: const Icon(Icons.tune),
                    ),
                  ),
                ),
              if (state is SessionPaused)
                Positioned.fill(
                  child: PauseOverlay(
                    onResume: cubit.resume,
                    onRestart: () => _restart(context),
                    onQuit: () => context.go(Routes.home),
                  ),
                ),
              if (state is SessionUpgradePicking)
                Positioned.fill(
                  child: UpgradePickerOverlay(
                    waveCleared: state.waveCleared,
                    choices: state.choices,
                    onPick: cubit.selectUpgrade,
                    rerollCost: state.rerollCost,
                    canReroll: state.canReroll,
                    onReroll: cubit.rerollDraft,
                  ),
                ),
              if (state is SessionAwaitingContinue)
                Positioned.fill(
                  child: ContinueOverlay(
                    wave: state.wave,
                    cost: state.cost,
                    onBuy: cubit.buyContinue,
                    onDecline: cubit.declineContinue,
                  ),
                ),
              if (state is SessionRunEnding)
                Positioned.fill(
                  child: RunEndingOverlay(
                    headline: state.headline,
                    detail: state.detail,
                    wave: state.wave,
                    onSkip: cubit.skipEnding,
                  ),
                ),
              if (state is SessionRunOver)
                Positioned.fill(
                  child: RunResultsOverlay(
                    result: state.result,
                    isNewBestScore: state.isNewBestScore,
                    unlockedAchievements: state.unlockedAchievements,
                    onRetry: () => _restart(context),
                    onHome: () => context.go(Routes.home),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openTuning(BuildContext context, DeadbounceGame game, HudModel hud) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TuningPanel(game: game, hud: hud),
    );
  }

  void _restart(BuildContext context) {
    final cubit = context.read<GameSessionCubit>();
    final tournament = cubit.tournamentContext;
    if (tournament != null) {
      // Restart the SAME tournament run, not a plain run.
      context.pushReplacement(
        '${Routes.tournamentRun}/${tournament.tournamentId}',
      );
      return;
    }
    context.pushReplacement(
      cubit.dailyChallenge ? Routes.dailyChallengeRun : Routes.game,
    );
  }
}
