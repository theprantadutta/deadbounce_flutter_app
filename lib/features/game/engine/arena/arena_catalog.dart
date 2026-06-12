import 'arena_definition.dart';

/// The three Phase-2 arenas — pure data. New arenas are new entries.
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

  static const List<ArenaDefinition> all = [cleanRect, pillars, angledCorners];

  static ArenaDefinition byId(String id) =>
      all.firstWhere((a) => a.id == id, orElse: () => cleanRect);
}
