import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/logging/app_logger.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/widgets/animated_arena_background.dart';
import '../../core/widgets/db_button.dart';
import '../../core/widgets/db_loading_scene.dart';
import '../game/engine/arena/arena_catalog.dart';
import '../game/engine/game_rng.dart';
import '../game/engine/upgrades/upgrade_card.dart';
import '../game/presentation/game/components/deadbounce_game.dart';
import '../game/presentation/game/game_feel.dart';
import '../game/presentation/game/game_session_gateway.dart';
import '../game/presentation/game/hud_model.dart';
import '../game/presentation/game/systems/flame_audio_sound_manager.dart';
import '../game/presentation/game/systems/haptics_service.dart';
import '../game/presentation/game/systems/sound_manager.dart';
import 'onboarding_store.dart';
import 'tutorial_steps.dart';

/// The interactive new-user walkthrough. Steps the player through the ricochet
/// rule with hands-on bounce practice (reusing the Trick-Shot engine) plus a
/// couple of info cards, then drops them into a real run.
///
/// Self-contained — its own no-op [GameSessionGateway], so it never touches the
/// run/leaderboard/stats path (like [TrickShotPage]). Shown once on first
/// launch (routed by the redirect gate) and replayable from Settings / How to
/// Play.
class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key, required this.store});

  final OnboardingStore store;

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage>
    with WidgetsBindingObserver
    implements GameSessionGateway {
  int _stepIndex = 0;
  bool _cleared = false; // brief "nice!" flash after a hands-on hit

  // Game + its deps for the current hands-on step. Rebuilt when the level
  // changes; torn down on info steps.
  DeadbounceGame? _game;
  HudModel? _hud;
  String? _builtLevelId;
  bool _building = false;

  // Cached once — the game engine needs settings/cosmetics/sound per build.
  SoundManager? _sound;
  bool _failed = false;

  TutorialStep get _step => TutorialScript.steps[_stepIndex];
  bool get _isLast => _stepIndex >= TutorialScript.steps.length - 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncGameForStep();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _game?.pauseEngine();
    } else if (state == AppLifecycleState.resumed) {
      _game?.resumeEngine();
    }
  }

  /// Ensures the live game matches the current step: build it for a hands-on
  /// step's level, tear it down for an info step.
  Future<void> _syncGameForStep() async {
    final step = _step;
    if (!step.isHandsOn) {
      _disposeGame();
      if (mounted) setState(() {});
      return;
    }
    if (_builtLevelId == step.level!.id) return;
    _disposeGame();
    setState(() => _building = true);
    try {
      await _buildGame(step);
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[tutorial] build failed');
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _buildGame(TutorialStep step) async {
    final session = context.sessionDependencies;
    final settings = await session.settingsRepository.load();
    final cosmetics = await session.cosmeticsRepository.loadout();
    final sound = _sound ??=
        FlameAudioSoundManager(enabled: settings.soundEnabled);
    final hud = HudModel();

    final game = DeadbounceGame(
      gateway: this,
      hud: hud,
      arenaDef: ArenaCatalog.byId(step.level!.arenaId),
      runRng: GameRng(1), // no RNG content in the tutorial; fixed for clarity
      sound: sound,
      hapticsService: HapticsService(enabled: settings.hapticsEnabled),
      trickShotLevel: step.level,
      cosmetics: cosmetics,
      gameFeel: GameFeel(
        screenShake: settings.screenShakeEnabled,
        hitStop: settings.hitStopEnabled,
        aimGuide: settings.aimGuideEnabled,
        combatText: settings.combatTextEnabled,
        particleBudget: settings.particleQuality.budget,
      ),
      onTrickShotProgress: (_) {},
      onTrickShotComplete: _onHandsOnCleared,
    );

    await sound.preload();
    if (!mounted) return;
    setState(() {
      _game = game;
      _hud = hud;
      _builtLevelId = step.level!.id;
      _building = false;
    });
  }

  void _onHandsOnCleared() {
    if (!mounted || _cleared) return;
    setState(() => _cleared = true);
    // A short beat to enjoy the hit, then advance.
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _advance();
    });
  }

  void _advance() {
    if (_isLast) {
      _finish(playNow: true);
      return;
    }
    setState(() {
      _stepIndex++;
      _cleared = false;
    });
    _syncGameForStep();
  }

  Future<void> _finish({required bool playNow}) async {
    await widget.store.markComplete();
    if (!mounted) return;
    // Replays push onto the stack (Settings/How-to-Play); if we can pop back
    // there, do — otherwise it's the first-launch gate, so go forward.
    if (!playNow && context.canPop()) {
      context.pop();
      return;
    }
    context.go(playNow ? Routes.game : Routes.home);
  }

  void _disposeGame() {
    _game?.pauseEngine();
    _game = null;
    _hud?.dispose();
    _hud = null;
    _builtLevelId = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeGame();
    _sound?.dispose();
    super.dispose();
  }

  // --- GameSessionGateway: no waves, no death in the tutorial. No-ops. ---
  @override
  void onWaveCleared(int wave, List<UpgradeCard> choices) {}

  @override
  void onRunEnded(RunStatsSnapshot stats) {}

  @override
  Widget build(BuildContext context) {
    if (_failed) return _errorScene(context);

    final step = _step;
    final stepNumber = _stepIndex + 1;
    final total = TutorialScript.steps.length;

    // Info step: a centered card over the shared cinematic background.
    if (!step.isHandsOn) {
      return Scaffold(
        body: AnimatedArenaBackground(
          child: SafeArea(
            child: Stack(
              children: [
                _SkipButton(onSkip: () => _finish(playNow: false)),
                Center(
                  child: _InfoCard(
                    step: step,
                    stepNumber: stepNumber,
                    total: total,
                    onContinue: _advance,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Hands-on step: live arena + a coach band. Loading while it builds.
    final game = _game;
    if (game == null || _building) {
      return const DbLoadingScene(
        title: 'SETTING UP THE RANGE',
        subtitle: 'Chalk your hands, partner.',
        showLogo: false,
        tips: ['Direct hits do nothing — bounce it in.'],
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: game)),
          // Coaching band — IgnorePointer so drags pass through to the arena.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SafeArea(
                bottom: false,
                child: _CoachBand(
                  step: step,
                  stepNumber: stepNumber,
                  total: total,
                  cleared: _cleared,
                ),
              ),
            ),
          ),
          SafeArea(child: _SkipButton(onSkip: () => _finish(playNow: false))),
        ],
      ),
    );
  }

  Widget _errorScene(BuildContext context) => Scaffold(
        body: AnimatedArenaBackground(
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Couldn't set up the tutorial.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DbSecondaryButton(
                    label: 'SKIP TO THE GAME',
                    onPressed: () => _finish(playNow: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: TextButton(
          onPressed: onSkip,
          child: Text(
            'SKIP',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: AppColors.ink300),
          ),
        ),
      ),
    );
  }
}

/// Compact top band that coaches a hands-on step.
class _CoachBand extends StatelessWidget {
  const _CoachBand({
    required this.step,
    required this.stepNumber,
    required this.total,
    required this.cleared,
  });

  final TutorialStep step;
  final int stepNumber;
  final int total;
  final bool cleared;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ink950.withValues(alpha: 0.82),
        borderRadius: AppRadii.lgAll,
        border: Border.all(
          color: cleared ? AppColors.amber400 : AppColors.outlineFaint,
        ),
      ),
      child: cleared
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.amber400, size: 22),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'NICE SHOT!',
                  style: textTheme.titleMedium
                      ?.copyWith(color: AppColors.amber300),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepLabel(stepNumber: stepNumber, total: total),
                const SizedBox(height: AppSpacing.xxs),
                Text(step.title, style: textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(step.body, style: textTheme.bodyMedium),
              ],
            ),
    );
  }
}

/// Centered card for an info step, with the continue button.
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.step,
    required this.stepNumber,
    required this.total,
    required this.onContinue,
  });

  final TutorialStep step;
  final int stepNumber;
  final int total;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.ink900.withValues(alpha: 0.86),
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: AppColors.amber500),
            boxShadow: [
              BoxShadow(
                color: AppColors.amber500.withValues(alpha: 0.18),
                blurRadius: 22,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepLabel(stepNumber: stepNumber, total: total),
              const SizedBox(height: AppSpacing.sm),
              Text(
                step.title,
                style: textTheme.headlineSmall
                    ?.copyWith(color: AppColors.amber300),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(step.body, style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              DbPrimaryButton(label: step.continueLabel, onPressed: onContinue),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({required this.stepNumber, required this.total});

  final int stepNumber;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Text(
      'STEP $stepNumber OF $total',
      style: Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(color: AppColors.blue300),
    );
  }
}
