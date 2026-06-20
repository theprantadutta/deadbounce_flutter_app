import 'package:flame/components.dart';

import '../arena/arena_catalog.dart';
import '../arena/arena_definition.dart';
import 'trickshot_level.dart';

/// The Trick-Shot Gallery — a hand-authored ladder of bounce puzzles that
/// double as the best teacher for the ricochet mechanic. Arena is
/// [ArenaDefinition.width] × [ArenaDefinition.height] (720 × 1280); the
/// player fires from the bottom third.
abstract final class TrickShotCatalog {
  static const double _w = ArenaDefinition.width;
  static const double _h = ArenaDefinition.height;

  static final List<TrickShotLevel> levels = [
    TrickShotLevel(
      id: 'ts_1',
      name: 'First Ricochet',
      arenaId: ArenaCatalog.cleanRect.id,
      par: 2,
      hint: 'No damage on a direct hit — bounce one off a wall first.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.22), requiredBounces: 1),
      ],
    ),
    TrickShotLevel(
      id: 'ts_2',
      name: 'Bank Shot',
      arenaId: ArenaCatalog.cleanRect.id,
      par: 3,
      hint: 'Two corners, two targets. Work the side walls.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.18, _h * 0.20), requiredBounces: 1),
        TrickShotTarget(position: Vector2(_w * 0.82, _h * 0.20), requiredBounces: 1),
      ],
    ),
    TrickShotLevel(
      id: 'ts_3',
      name: 'Double Tap',
      arenaId: ArenaCatalog.angledCorners.id,
      par: 3,
      hint: 'Rack up two bounces before you reach the high mark.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.16), requiredBounces: 2),
        TrickShotTarget(position: Vector2(_w * 0.30, _h * 0.34), requiredBounces: 1),
      ],
    ),
    TrickShotLevel(
      id: 'ts_4',
      name: 'Pillar Talk',
      arenaId: ArenaCatalog.pillars.id,
      par: 4,
      hint: 'Use the pillars — line the bounce up behind cover.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.20, _h * 0.26), requiredBounces: 2),
        TrickShotTarget(position: Vector2(_w * 0.80, _h * 0.26), requiredBounces: 2),
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.12), requiredBounces: 1),
      ],
    ),
    TrickShotLevel(
      id: 'ts_5',
      name: 'Ricochet Royalty',
      arenaId: ArenaCatalog.angledCorners.id,
      par: 5,
      hint: 'Three bounces minimum on the crown. Earn it.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.10), requiredBounces: 3),
        TrickShotTarget(position: Vector2(_w * 0.22, _h * 0.30), requiredBounces: 2),
        TrickShotTarget(position: Vector2(_w * 0.78, _h * 0.30), requiredBounces: 2),
      ],
    ),
  ];

  static TrickShotLevel byId(String id) =>
      levels.firstWhere((l) => l.id == id, orElse: () => levels.first);
}
