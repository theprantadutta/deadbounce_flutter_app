import 'package:flame/components.dart';

import '../game/engine/arena/arena_catalog.dart';
import '../game/engine/arena/arena_definition.dart';
import '../game/engine/trickshot/trickshot_level.dart';

/// One beat of the interactive walkthrough.
///
/// A step is either **hands-on** — it carries a one-target [TrickShotLevel] the
/// player must clear to advance (reusing the Trick-Shot engine, "the best
/// teacher for the core mechanic") — or an **info** card the player dismisses
/// with the continue button.
class TutorialStep {
  const TutorialStep({
    required this.title,
    required this.body,
    this.level,
    this.continueLabel = 'GOT IT',
  });

  /// Coach-mark heading.
  final String title;

  /// Coach-mark body copy (Deadbounce voice, mirrors How-to-Play).
  final String body;

  /// Non-null → hands-on: clear this level (one target) to advance.
  /// Null → info card, dismissed with [continueLabel].
  final TrickShotLevel? level;

  /// Label for the continue button on info steps.
  final String continueLabel;

  bool get isHandsOn => level != null;
}

/// The ordered walkthrough: the rule → aim & bank a shot → a two-bounce bank →
/// dash → graduate into a real run.
abstract final class TutorialScript {
  static const double _w = ArenaDefinition.width;
  static const double _h = ArenaDefinition.height;

  static final List<TutorialStep> steps = [
    const TutorialStep(
      title: 'THE GOLDEN RULE',
      body: 'Your bullets do ZERO damage on a direct hit. They only turn '
          'lethal after ricocheting off a wall — each bounce adds power. '
          "Let's bank one in.",
      continueLabel: "LET'S GO",
    ),
    TutorialStep(
      title: 'DRAG TO AIM',
      body: 'Drag anywhere to aim — the glowing line shows your ricochet. '
          'Bank a shot off a wall to break the target. A straight hit passes '
          'right through it.',
      level: _oneTarget(
        id: 'tut_aim',
        pos: Vector2(_w * 0.5, _h * 0.20),
        requiredBounces: 1,
        hint: 'Bounce it off a wall.',
      ),
    ),
    TutorialStep(
      title: 'GO DEEPER',
      body: 'More bounces, more damage. This target only breaks after TWO '
          'ricochets — work the side walls to rack them up.',
      level: _oneTarget(
        id: 'tut_double',
        pos: Vector2(_w * 0.5, _h * 0.16),
        requiredBounces: 2,
        arenaId: ArenaCatalog.angledCorners.id,
        hint: 'Two bounces before it lands.',
      ),
    ),
    const TutorialStep(
      title: 'TAP TO DASH',
      body: 'A quick tap dashes you between three spots along the bottom. '
          'Aiming is the skill — dashing is just for dodging enemies.',
    ),
    const TutorialStep(
      title: "YOU'RE READY",
      body: 'Clear waves, pick upgrade cards, and chain your bounces through a '
          'crowd. Now go turn the arena into your weapon.',
      continueLabel: 'ENTER THE ARENA',
    ),
  ];

  static TrickShotLevel _oneTarget({
    required String id,
    required Vector2 pos,
    required int requiredBounces,
    required String hint,
    String? arenaId,
  }) =>
      TrickShotLevel(
        id: id,
        name: 'Tutorial',
        arenaId: arenaId ?? ArenaCatalog.cleanRect.id,
        par: requiredBounces + 2,
        hint: hint,
        targets: [
          TrickShotTarget(position: pos, requiredBounces: requiredBounces),
        ],
      );
}
