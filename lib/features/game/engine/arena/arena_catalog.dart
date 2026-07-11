import 'arena_definition.dart';

/// The arena roster — pure data. New arenas are just new entries (the shared
/// solver + aim preview handle any geometry; the trajectory-parity test covers
/// each). 9 arenas: 3 originals + 6 authored in Phase 3.
abstract final class ArenaCatalog {
  static const ArenaDefinition cleanRect = ArenaDefinition(
    id: 'arena_clean',
    displayName: 'THE YARD',
    flavor: 'Four walls. No excuses.',
    obstacles: [],
    playerAnchors: [(150, 1100), (360, 1060), (570, 1100)],
    spawnZones: [
      SpawnZone(rect: ZoneRect(60, 40, 600, 140)),
      SpawnZone(rect: ZoneRect(20, 200, 90, 400), edge: SpawnEdge.left),
      SpawnZone(rect: ZoneRect(610, 200, 90, 400), edge: SpawnEdge.right),
    ],
    turretSlotWalls: [1, 3],
  );

  static const ArenaDefinition pillars = ArenaDefinition(
    id: 'arena_pillars',
    displayName: 'TWIN POSTS',
    flavor: 'Two pillars. Twice the angles.',
    obstacles: [
      // Left pillar
      [(180, 520), (260, 520), (260, 680), (180, 680)],
      // Right pillar
      [(460, 520), (540, 520), (540, 680), (460, 680)],
    ],
    playerAnchors: [(140, 1110), (360, 1070), (580, 1110)],
    spawnZones: [
      SpawnZone(rect: ZoneRect(60, 40, 600, 140)),
      SpawnZone(rect: ZoneRect(20, 220, 90, 360), edge: SpawnEdge.left),
      SpawnZone(rect: ZoneRect(610, 220, 90, 360), edge: SpawnEdge.right),
    ],
    turretSlotWalls: [1, 3],
  );

  static const ArenaDefinition angledCorners = ArenaDefinition(
    id: 'arena_angled',
    displayName: 'THE BEVEL',
    flavor: 'Cut corners. Mean rebounds.',
    obstacles: [],
    playerAnchors: [(160, 1090), (360, 1050), (560, 1090)],
    spawnZones: [
      SpawnZone(rect: ZoneRect(80, 60, 560, 140)),
      SpawnZone(rect: ZoneRect(20, 260, 90, 340), edge: SpawnEdge.left),
      SpawnZone(rect: ZoneRect(610, 260, 90, 340), edge: SpawnEdge.right),
    ],
    turretSlotWalls: [2, 6],
    cornerCut: 140,
  );

  // ---------------------------------------------------------------------------
  // Phase 3 — feed the ricochet hook. More interior geometry = more obvious
  // 2–3 bounce lines from the bottom anchors. All pure data; the shared solver
  // + aim preview handle them for free (trajectory parity test covers each).
  // ---------------------------------------------------------------------------

  /// Central diamond island — every face is a diagonal, so bank shots off it
  /// come back at a fresh angle.
  static const ArenaDefinition crossfire = ArenaDefinition(
    id: 'arena_crossfire',
    displayName: 'CROSSFIRE',
    flavor: 'A diamond in the crossfire.',
    obstacles: [
      [(360, 508), (452, 600), (360, 692), (268, 600)],
    ],
    playerAnchors: [(150, 1100), (360, 1060), (570, 1100)],
    spawnZones: [
      SpawnZone(rect: ZoneRect(60, 40, 600, 140)),
      SpawnZone(rect: ZoneRect(20, 200, 90, 400), edge: SpawnEdge.left),
      SpawnZone(rect: ZoneRect(610, 200, 90, 400), edge: SpawnEdge.right),
    ],
    turretSlotWalls: [1, 3],
  );

  /// Staggered half-walls, offset like swinging saloon doors — thread the gap
  /// or bank over the top.
  static const ArenaDefinition saloon = ArenaDefinition(
    id: 'arena_saloon',
    displayName: 'SWINGING DOORS',
    flavor: 'Two half-walls. Mind the gap.',
    obstacles: [
      [(90, 556), (340, 556), (340, 584), (90, 584)],
      [(380, 704), (630, 704), (630, 732), (380, 732)],
    ],
    playerAnchors: [(150, 1120), (360, 1080), (570, 1120)],
    spawnZones: [
      SpawnZone(rect: ZoneRect(60, 40, 600, 140)),
      SpawnZone(rect: ZoneRect(20, 200, 90, 320), edge: SpawnEdge.left),
      SpawnZone(rect: ZoneRect(610, 200, 90, 320), edge: SpawnEdge.right),
    ],
    turretSlotWalls: [1, 3],
  );

  /// Two wall wedges pinch the arena to a narrow waist — angled faces that
  /// funnel a bounce straight back down the middle.
  static const ArenaDefinition hourglass = ArenaDefinition(
    id: 'arena_hourglass',
    displayName: 'THE PINCH',
    flavor: 'Sand runs thin through the middle.',
    obstacles: [
      [(112, 470), (340, 600), (112, 730)],
      [(608, 470), (380, 600), (608, 730)],
    ],
    playerAnchors: [(150, 1110), (360, 1070), (570, 1110)],
    spawnZones: [
      SpawnZone(rect: ZoneRect(60, 40, 600, 140)),
      SpawnZone(rect: ZoneRect(20, 220, 80, 200), edge: SpawnEdge.left),
      SpawnZone(rect: ZoneRect(620, 220, 80, 200), edge: SpawnEdge.right),
    ],
    turretSlotWalls: [1, 3],
  );

  /// Two tall posts frame a central chute — vertical faces built for
  /// side-wall bank shots down the lane.
  static const ArenaDefinition chute = ArenaDefinition(
    id: 'arena_chute',
    displayName: 'THE CHUTE',
    flavor: 'Straight down the gullet.',
    obstacles: [
      [(210, 420), (238, 420), (238, 780), (210, 780)],
      [(482, 420), (510, 420), (510, 780), (482, 780)],
    ],
    playerAnchors: [(150, 1110), (360, 1070), (570, 1110)],
    spawnZones: [
      SpawnZone(rect: ZoneRect(60, 40, 600, 140)),
      SpawnZone(rect: ZoneRect(20, 200, 90, 400), edge: SpawnEdge.left),
      SpawnZone(rect: ZoneRect(610, 200, 90, 400), edge: SpawnEdge.right),
    ],
    turretSlotWalls: [1, 3],
  );

  /// A chevron band across the upper arena — a wishbone of diagonal faces to
  /// split shots off, left or right.
  static const ArenaDefinition wishbone = ArenaDefinition(
    id: 'arena_wishbone',
    displayName: 'THE WISHBONE',
    flavor: 'Break it clean down the center.',
    obstacles: [
      [
        (160, 470),
        (360, 610),
        (560, 470),
        (560, 522),
        (360, 662),
        (160, 522),
      ],
    ],
    playerAnchors: [(150, 1100), (360, 1060), (570, 1100)],
    spawnZones: [
      SpawnZone(rect: ZoneRect(60, 40, 600, 140)),
      SpawnZone(rect: ZoneRect(20, 220, 90, 380), edge: SpawnEdge.left),
      SpawnZone(rect: ZoneRect(610, 220, 90, 380), edge: SpawnEdge.right),
    ],
    turretSlotWalls: [1, 3],
  );

  /// A 2×2 grid of posts — the busiest ricochet playground, sixteen faces of
  /// angles to work.
  static const ArenaDefinition fourPosts = ArenaDefinition(
    id: 'arena_fourposts',
    displayName: 'FOUR CORNERS',
    flavor: 'Four posts. Sixteen angles.',
    obstacles: [
      [(210, 500), (270, 500), (270, 560), (210, 560)],
      [(450, 500), (510, 500), (510, 560), (450, 560)],
      [(210, 720), (270, 720), (270, 780), (210, 780)],
      [(450, 720), (510, 720), (510, 780), (450, 780)],
    ],
    playerAnchors: [(150, 1110), (360, 1070), (570, 1110)],
    spawnZones: [
      SpawnZone(rect: ZoneRect(60, 40, 600, 140)),
      SpawnZone(rect: ZoneRect(20, 200, 90, 260), edge: SpawnEdge.left),
      SpawnZone(rect: ZoneRect(610, 200, 90, 260), edge: SpawnEdge.right),
    ],
    turretSlotWalls: [1, 3],
  );

  static const List<ArenaDefinition> all = [
    cleanRect,
    pillars,
    angledCorners,
    crossfire,
    saloon,
    hourglass,
    chute,
    wishbone,
    fourPosts,
  ];

  static ArenaDefinition byId(String id) =>
      all.firstWhere((a) => a.id == id, orElse: () => cleanRect);
}
