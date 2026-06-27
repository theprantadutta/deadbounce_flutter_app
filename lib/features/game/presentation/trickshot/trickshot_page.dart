import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/animated_arena_background.dart';
import '../../../../core/widgets/db_button.dart';
import '../../../../core/widgets/db_loading_scene.dart';
import '../../engine/arena/arena_catalog.dart';
import '../../engine/game_rng.dart';
import '../../engine/trickshot/trickshot_catalog.dart';
import '../../engine/trickshot/trickshot_level.dart';
import '../../engine/upgrades/upgrade_card.dart';
import '../game/components/deadbounce_game.dart';
import '../game/game_feel.dart';
import '../game/game_session_gateway.dart';
import '../game/hud_model.dart';
import '../game/systems/flame_audio_sound_manager.dart';
import '../game/systems/haptics_service.dart';
import '../game/systems/sound_manager.dart';

/// Hosts a single Trick-Shot level. Self-contained (its own no-op
/// [GameSessionGateway]) so it never touches the run/leaderboard path — a
/// trick-shot clear is a puzzle win, not a scored run.
class TrickShotPage extends StatefulWidget {
  const TrickShotPage({super.key, required this.levelId});

  final String levelId;

  @override
  State<TrickShotPage> createState() => _TrickShotPageState();
}

class _TrickShotPageState extends State<TrickShotPage>
    with WidgetsBindingObserver
    implements GameSessionGateway {
  late final TrickShotLevel _level = TrickShotCatalog.byId(widget.levelId);
  final HudModel _hud = HudModel();
  final ValueNotifier<int> _remaining = ValueNotifier(0);

  DeadbounceGame? _game;
  SoundManager? _sound;
  bool _complete = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _game?.pauseEngine();
    } else if (state == AppLifecycleState.resumed && !_complete) {
      _game?.resumeEngine();
    }
  }

  Future<void> _start() async {
    try {
      await _build();
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[trickshot] start failed');
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _build() async {
    final session = context.sessionDependencies;
    final progressRepo = session.trickShotProgressRepository;
    final settings = await session.settingsRepository.load();
    final cosmetics = await session.cosmeticsRepository.loadout();
    final sound = FlameAudioSoundManager(enabled: settings.soundEnabled);
    _sound = sound;

    final game = DeadbounceGame(
      gateway: this,
      hud: _hud,
      arenaDef: ArenaCatalog.byId(_level.arenaId),
      runRng: GameRng(1), // no RNG content in trick-shot; fixed for clarity
      sound: sound,
      hapticsService: HapticsService(enabled: settings.hapticsEnabled),
      trickShotLevel: _level,
      cosmetics: cosmetics,
      gameFeel: GameFeel(
        screenShake: settings.screenShakeEnabled,
        hitStop: settings.hitStopEnabled,
        aimGuide: settings.aimGuideEnabled,
        combatText: settings.combatTextEnabled,
        particleBudget: settings.particleQuality.budget,
      ),
      onTrickShotProgress: (r) => _remaining.value = r,
      onTrickShotComplete: () {
        if (!mounted) return;
        // Persist the clear locally (offline-first), keeping the best shots.
        unawaited(progressRepo.recordClear(_level.id, _shotsUsed));
        setState(() => _complete = true);
      },
    );

    _remaining.value = _level.targets.length;
    await sound.preload();
    if (!mounted) return;
    setState(() => _game = game);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop the Flame loop before disposing the HUD notifiers (see cubit.close).
    _game?.pauseEngine();
    _hud.dispose();
    _remaining.dispose();
    _sound?.dispose();
    super.dispose();
  }

  // --- GameSessionGateway: trick-shot has no waves and no death, so these
  //     never fire. Implemented as no-ops to satisfy the contract. ---
  @override
  void onWaveCleared(int wave, List<UpgradeCard> choices) {}

  @override
  void onRunEnded(RunStatsSnapshot stats) {}

  int get _shotsUsed => _game?.player.shotCounter ?? 0;

  String? get _nextLevelId {
    final levels = TrickShotCatalog.levels;
    final i = levels.indexWhere((l) => l.id == _level.id);
    return (i >= 0 && i + 1 < levels.length) ? levels[i + 1].id : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Scaffold(
        body: AnimatedArenaBackground(
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Couldn't set up the gallery.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DbSecondaryButton(
                    label: 'BACK TO GALLERY',
                    onPressed: () => context.go(Routes.trickShot),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final game = _game;
    if (game == null) {
      return const DbLoadingScene(
        title: 'SETTING UP THE GALLERY',
        subtitle: 'Chalk your hands, partner.',
        showLogo: false,
        tips: ['Direct hits do nothing — bounce it in.'],
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: game)),
          _TopBar(level: _level, remaining: _remaining),
          if (_complete)
            Positioned.fill(
              child: _CompleteOverlay(
                level: _level,
                shotsUsed: _shotsUsed,
                nextLevelId: _nextLevelId,
              ),
            ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.level, required this.remaining});

  final TrickShotLevel level;
  final ValueNotifier<int> remaining;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: () => context.go(Routes.trickShot),
              icon: const Icon(Icons.close, size: 22),
              color: AppColors.ink100,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.name.toUpperCase(),
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.blue300,
                    ),
                  ),
                  Text(
                    level.hint,
                    style: textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ValueListenableBuilder<int>(
              valueListenable: remaining,
              builder: (context, r, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.my_location,
                    size: 16,
                    color: AppColors.amber400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$r left',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.amber300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompleteOverlay extends StatelessWidget {
  const _CompleteOverlay({
    required this.level,
    required this.shotsUsed,
    required this.nextLevelId,
  });

  final TrickShotLevel level;
  final int shotsUsed;
  final String? nextLevelId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final underPar = shotsUsed <= level.par;

    return AnimatedArenaBackground(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'TARGETS DOWN',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.amber300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    underPar
                        ? 'Clean shooting — $shotsUsed shots (par ${level.par}).'
                        : '$shotsUsed shots (par ${level.par}). Tighten it up.',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (nextLevelId != null)
                    DbPrimaryButton(
                      label: 'NEXT LEVEL',
                      onPressed: () => context.pushReplacement(
                        '${Routes.trickShotRun}/$nextLevelId',
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  DbSecondaryButton(
                    label: 'RETRY',
                    onPressed: () => context.pushReplacement(
                      '${Routes.trickShotRun}/${level.id}',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  DbSecondaryButton(
                    label: 'BACK TO GALLERY',
                    onPressed: () => context.go(Routes.trickShot),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
