import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_effects.dart';
import 'game/deadbounce_game.dart';

/// Hosts the empty Flame arena. The GameWidget fills the screen; the
/// game's fixed-resolution camera letterboxes so the arena keeps its
/// proportions on every device.
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // Keep one game instance across rebuilds — recreating a FlameGame in
  // build() restarts the engine on every setState.
  late final DeadbounceGame _game = DeadbounceGame();

  @override
  Widget build(BuildContext context) {
    final effects = Theme.of(context).extension<AppEffects>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GameWidget(game: _game),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: effects.glassDecoration,
                    child: IconButton(
                      tooltip: 'Back to menu',
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: effects.glassDecoration,
                    child: Text('THE ARENA', style: textTheme.labelMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
