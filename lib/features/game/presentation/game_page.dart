import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/db_loading_scene.dart';
import 'cubit/game_session_cubit.dart';
import 'debug/tuning_panel.dart';
import 'game/components/deadbounce_game.dart';
import 'game/hud_model.dart';
import 'overlays/hud_overlay.dart';
import 'overlays/pause_overlay.dart';
import 'overlays/run_ending_overlay.dart';
import 'overlays/run_results_overlay.dart';
import 'overlays/upgrade_picker_overlay.dart';

/// Hosts the arena. All chrome (HUD, pause, upgrade picker, results) is
/// normal Flutter widgets stacked over the GameWidget, driven by the
/// session cubit — the game pauses underneath the overlays.
class GamePage extends StatelessWidget {
  const GamePage({super.key, this.dailyChallenge = false});

  final bool dailyChallenge;

  @override
  Widget build(BuildContext context) {
    final session = context.sessionDependencies;
    return BlocProvider(
      create: (_) => GameSessionCubit(
        runsRepository: session.runsRepository,
        achievementsRepository: session.achievementsRepository,
        settingsRepository: session.settingsRepository,
        syncWorker: session.syncWorker,
        dailyChallenge: dailyChallenge,
      )..startRun(),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameSessionCubit>();

    return Scaffold(
      body: BlocBuilder<GameSessionCubit, GameSessionState>(
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
    final dailyChallenge = context.read<GameSessionCubit>().dailyChallenge;
    context.pushReplacement(
      dailyChallenge ? Routes.dailyChallengeRun : Routes.game,
    );
  }
}
