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

    // --- Phase 3 additions. New arenas + explicit chain teachers ("one
    // bullet, many marks", low par) since the tutorial never covers chaining.
    // Bullets persist through targets, so a single bounced slug can sweep a
    // row — that's the whole game. requiredBounces is a FLOOR (over-bounce is
    // fine), so every mark is reachable. ---
    TrickShotLevel(
      id: 'ts_6',
      name: 'Twin Marks',
      arenaId: ArenaCatalog.cleanRect.id,
      par: 1,
      hint: 'One bullet, both marks — bank it flat across the row.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.30, _h * 0.20), requiredBounces: 1),
        TrickShotTarget(position: Vector2(_w * 0.70, _h * 0.20), requiredBounces: 1),
      ],
    ),
    TrickShotLevel(
      id: 'ts_7',
      name: 'Rico Row',
      arenaId: ArenaCatalog.cleanRect.id,
      par: 2,
      hint: 'A flat bank can sweep the whole line in one.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.25, _h * 0.22), requiredBounces: 1),
        TrickShotTarget(position: Vector2(_w * 0.50, _h * 0.22), requiredBounces: 1),
        TrickShotTarget(position: Vector2(_w * 0.75, _h * 0.22), requiredBounces: 1),
      ],
    ),
    TrickShotLevel(
      id: 'ts_8',
      name: 'The Pinch',
      arenaId: ArenaCatalog.hourglass.id,
      par: 2,
      hint: 'Funnel it through the waist.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.30), requiredBounces: 2),
      ],
    ),
    TrickShotLevel(
      id: 'ts_9',
      name: 'Down the Chute',
      arenaId: ArenaCatalog.chute.id,
      par: 2,
      hint: 'Straight down the gullet — off a post and back.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.42), requiredBounces: 2),
      ],
    ),
    TrickShotLevel(
      id: 'ts_10',
      name: 'Over the Doors',
      arenaId: ArenaCatalog.saloon.id,
      par: 2,
      hint: 'Bank over the swinging doors to both sides.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.28, _h * 0.30), requiredBounces: 1),
        TrickShotTarget(position: Vector2(_w * 0.72, _h * 0.30), requiredBounces: 1),
      ],
    ),
    TrickShotLevel(
      id: 'ts_11',
      name: 'Split the Wishbone',
      arenaId: ArenaCatalog.wishbone.id,
      par: 2,
      hint: 'Break it clean down the center.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.16), requiredBounces: 2),
      ],
    ),
    TrickShotLevel(
      id: 'ts_12',
      name: 'Thread the Posts',
      arenaId: ArenaCatalog.fourPosts.id,
      par: 2,
      hint: 'Weave between the corners.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.34), requiredBounces: 2),
      ],
    ),
    TrickShotLevel(
      id: 'ts_13',
      name: 'Diamond Cut',
      arenaId: ArenaCatalog.crossfire.id,
      par: 3,
      hint: "Bank off the island's faces, both ways.",
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.22, _h * 0.24), requiredBounces: 2),
        TrickShotTarget(position: Vector2(_w * 0.78, _h * 0.24), requiredBounces: 2),
      ],
    ),
    TrickShotLevel(
      id: 'ts_14',
      name: 'Pillar Weave',
      arenaId: ArenaCatalog.pillars.id,
      par: 3,
      hint: 'Use the posts for cover angles.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.12), requiredBounces: 1),
        TrickShotTarget(position: Vector2(_w * 0.20, _h * 0.30), requiredBounces: 2),
        TrickShotTarget(position: Vector2(_w * 0.80, _h * 0.30), requiredBounces: 2),
      ],
    ),
    TrickShotLevel(
      id: 'ts_15',
      name: 'Waist Deep',
      arenaId: ArenaCatalog.hourglass.id,
      par: 3,
      hint: 'Pinch through, then fan out.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.32, _h * 0.24), requiredBounces: 2),
        TrickShotTarget(position: Vector2(_w * 0.68, _h * 0.24), requiredBounces: 2),
      ],
    ),
    TrickShotLevel(
      id: 'ts_16',
      name: 'Lane Runner',
      arenaId: ArenaCatalog.chute.id,
      par: 3,
      hint: 'Down the lane and deeper — two off the posts.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.20), requiredBounces: 1),
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.50), requiredBounces: 2),
      ],
    ),
    TrickShotLevel(
      id: 'ts_17',
      name: 'Sixteen Angles',
      arenaId: ArenaCatalog.fourPosts.id,
      par: 3,
      hint: 'Sixteen faces, three marks.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.16), requiredBounces: 1),
        TrickShotTarget(position: Vector2(_w * 0.30, _h * 0.28), requiredBounces: 2),
        TrickShotTarget(position: Vector2(_w * 0.70, _h * 0.28), requiredBounces: 2),
      ],
    ),
    TrickShotLevel(
      id: 'ts_18',
      name: 'Deep Cut',
      arenaId: ArenaCatalog.angledCorners.id,
      par: 3,
      hint: 'Three off the bevels before the mark.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.10), requiredBounces: 3),
      ],
    ),
    TrickShotLevel(
      id: 'ts_19',
      name: 'Bevel Sweep',
      arenaId: ArenaCatalog.angledCorners.id,
      par: 2,
      hint: 'Cut the corner, sweep the pair.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.28, _h * 0.18), requiredBounces: 1),
        TrickShotTarget(position: Vector2(_w * 0.72, _h * 0.18), requiredBounces: 1),
      ],
    ),
    TrickShotLevel(
      id: 'ts_20',
      name: 'Island Hop',
      arenaId: ArenaCatalog.crossfire.id,
      par: 4,
      hint: 'Around the diamond, mark to mark.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.12), requiredBounces: 2),
        TrickShotTarget(position: Vector2(_w * 0.18, _h * 0.30), requiredBounces: 2),
        TrickShotTarget(position: Vector2(_w * 0.82, _h * 0.30), requiredBounces: 2),
      ],
    ),
    TrickShotLevel(
      id: 'ts_21',
      name: 'Doors & Dust',
      arenaId: ArenaCatalog.saloon.id,
      par: 4,
      hint: 'Three marks, over and under the doors.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.14), requiredBounces: 2),
        TrickShotTarget(position: Vector2(_w * 0.22, _h * 0.32), requiredBounces: 1),
        TrickShotTarget(position: Vector2(_w * 0.78, _h * 0.32), requiredBounces: 1),
      ],
    ),
    TrickShotLevel(
      id: 'ts_22',
      name: 'The Full Crown',
      arenaId: ArenaCatalog.angledCorners.id,
      par: 5,
      hint: 'The whole crown. Bank it and earn it.',
      targets: [
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.09), requiredBounces: 3),
        TrickShotTarget(position: Vector2(_w * 0.20, _h * 0.26), requiredBounces: 2),
        TrickShotTarget(position: Vector2(_w * 0.80, _h * 0.26), requiredBounces: 2),
        TrickShotTarget(position: Vector2(_w * 0.5, _h * 0.40), requiredBounces: 1),
      ],
    ),
  ];

  static TrickShotLevel byId(String id) =>
      levels.firstWhere((l) => l.id == id, orElse: () => levels.first);
}
