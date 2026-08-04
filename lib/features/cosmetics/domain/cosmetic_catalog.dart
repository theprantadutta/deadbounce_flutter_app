import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// The three cosmetic slots. Drift stores the enum `.name` (e.g. `bulletTrail`);
/// the sync wire (cosmeticState + snapshot) uses the snake_case [wireName]
/// (`bullet_trail`), matching the backend's snake_case JSON convention.
enum CosmeticSlot { bulletTrail, gunslinger, arenaTheme }

extension CosmeticSlotLabel on CosmeticSlot {
  String get label => switch (this) {
        CosmeticSlot.bulletTrail => 'Trails',
        CosmeticSlot.gunslinger => 'Gunslingers',
        CosmeticSlot.arenaTheme => 'Arenas',
      };

  IconData get icon => switch (this) {
        CosmeticSlot.bulletTrail => Icons.auto_graph,
        CosmeticSlot.gunslinger => Icons.person,
        CosmeticSlot.arenaTheme => Icons.grid_on,
      };

  /// snake_case key used on the sync wire, so the `cosmeticState` event the
  /// client emits matches the casing the backend stores and returns in the
  /// snapshot.
  String get wireName => switch (this) {
        CosmeticSlot.bulletTrail => 'bullet_trail',
        CosmeticSlot.gunslinger => 'gunslinger',
        CosmeticSlot.arenaTheme => 'arena_theme',
      };
}

/// A purchasable, VISUAL-ONLY cosmetic. [primary]/[secondary] are the colors
/// the game applies for this look — never any gameplay number (that would
/// break fairness and the no-damage-till-it-bounces rule). Free defaults
/// (cost 0) are implicitly owned.
@immutable
class Cosmetic {
  const Cosmetic({
    required this.id,
    required this.name,
    required this.blurb,
    required this.slot,
    required this.cost,
    required this.primary,
    required this.secondary,
    this.grantOnly = false,
  });

  final String id;
  final String name;
  final String blurb;
  final CosmeticSlot slot;
  final int cost;
  final Color primary;
  final Color secondary;

  /// Cannot be bought with coins — it only arrives as a grant from a verified
  /// real-money purchase (the Supporter Pack).
  ///
  /// Needed because `cost: 0` means "free stock, everybody owns it". An
  /// exclusive is also priced at 0 in coin terms, so without this flag it
  /// would be handed to every player on install — the opposite of exclusive.
  final bool grantOnly;

  /// Free stock looks, implicitly owned by everyone. Grant-only items are
  /// deliberately excluded even though they cost no coins.
  bool get isFree => cost == 0 && !grantOnly;
}

/// The cosmetics store. Pure Dart definitions; ownership/equip live in Drift.
abstract final class CosmeticCatalog {
  // --- Bullet trails (primary = trail color) ---
  static const trailDefault = Cosmetic(
    id: 'trail_default',
    name: 'Muzzle Gold',
    blurb: 'The classic amber streak.',
    slot: CosmeticSlot.bulletTrail,
    cost: 0,
    primary: AppColors.amber400,
    secondary: AppColors.amber200,
  );

  static const List<Cosmetic> all = [
    // Trails.
    trailDefault,
    Cosmetic(
      id: 'trail_ice',
      name: 'Cold Iron',
      blurb: 'An icy electric-blue tracer.',
      slot: CosmeticSlot.bulletTrail,
      cost: 200,
      primary: AppColors.blue400,
      secondary: AppColors.blue200,
    ),
    Cosmetic(
      id: 'trail_venom',
      name: 'Sidewinder',
      blurb: 'A venom-green streak with a bite.',
      slot: CosmeticSlot.bulletTrail,
      cost: 300,
      primary: AppColors.success,
      secondary: Color(0xFFB6FFD0),
    ),
    Cosmetic(
      id: 'trail_rose',
      name: 'Deadwood Rose',
      blurb: 'A hot crimson ribbon.',
      slot: CosmeticSlot.bulletTrail,
      cost: 350,
      primary: AppColors.error,
      secondary: Color(0xFFFFB3BB),
    ),
    Cosmetic(
      id: 'trail_bone',
      name: 'Bonepicker',
      blurb: 'A pale, dusty streak of old ivory.',
      slot: CosmeticSlot.bulletTrail,
      cost: 450,
      primary: Color(0xFFE8E0C8),
      secondary: Color(0xFFB8AE90),
    ),
    Cosmetic(
      id: 'trail_copper',
      name: 'Copperhead',
      blurb: 'Warm hammered copper with a dull sheen.',
      slot: CosmeticSlot.bulletTrail,
      cost: 600,
      primary: Color(0xFFC87137),
      secondary: Color(0xFFE8A264),
    ),
    Cosmetic(
      id: 'trail_ultraviolet',
      name: 'Ultraviolet',
      blurb: 'A humming violet arc that hurts to look at.',
      slot: CosmeticSlot.bulletTrail,
      cost: 900,
      primary: Color(0xFF8B3DFF),
      secondary: Color(0xFFD9B4FF),
    ),
    // ---- Legendary trail ----
    Cosmetic(
      id: 'trail_eclipse',
      name: 'Eclipse',
      blurb: 'A black core ringed in corona white. Nothing else looks like it.',
      slot: CosmeticSlot.bulletTrail,
      cost: 2200,
      primary: Color(0xFF120C1C),
      secondary: Color(0xFFFFF4D6),
    ),
    // Granted by the Supporter Pack only — never on sale for coins. Still
    // strictly visual, so it stays fair in every mode.
    Cosmetic(
      id: 'trail_supporter',
      name: "Gunsmith's Gratitude",
      blurb: 'A molten gold-and-white streak. Supporters only.',
      slot: CosmeticSlot.bulletTrail,
      cost: 0,
      grantOnly: true,
      primary: Color(0xFFFFE9A8),
      secondary: Color(0xFFFFFFFF),
    ),

    // Gunslingers (primary = core, secondary = trim).
    Cosmetic(
      id: 'skin_default',
      name: 'The Drifter',
      blurb: 'Amber core, electric-blue trim. Stock iron.',
      slot: CosmeticSlot.gunslinger,
      cost: 0,
      primary: AppColors.amber500,
      secondary: AppColors.blue400,
    ),
    Cosmetic(
      id: 'skin_outlaw',
      name: 'Black Hat',
      blurb: 'Gunmetal core under an amber halo.',
      slot: CosmeticSlot.gunslinger,
      cost: 400,
      primary: Color(0xFF2B2F3A),
      secondary: AppColors.amber400,
    ),
    Cosmetic(
      id: 'skin_marshal',
      name: 'The Marshal',
      blurb: 'White-hot core, cold-steel ring.',
      slot: CosmeticSlot.gunslinger,
      cost: 400,
      primary: Color(0xFFF4F5FB),
      secondary: AppColors.blue300,
    ),
    Cosmetic(
      id: 'skin_phantom',
      name: 'Phantom',
      blurb: 'A violet specter on the line.',
      slot: CosmeticSlot.gunslinger,
      cost: 500,
      primary: Color(0xFF9D5CFF),
      secondary: Color(0xFFC9A2FF),
    ),
    Cosmetic(
      id: 'skin_ranger',
      name: 'Sagebrush Ranger',
      blurb: 'Weathered olive under a brass ring.',
      slot: CosmeticSlot.gunslinger,
      cost: 550,
      primary: Color(0xFF5C6B3F),
      secondary: Color(0xFFD9A441),
    ),
    Cosmetic(
      id: 'skin_undertaker',
      name: 'The Undertaker',
      blurb: 'Funeral black with a bone-white halo.',
      slot: CosmeticSlot.gunslinger,
      cost: 700,
      primary: Color(0xFF14121A),
      secondary: Color(0xFFE8E0C8),
    ),
    Cosmetic(
      id: 'skin_bounty',
      name: 'Bounty Hunter',
      blurb: 'Rust-red plate over a molten seam.',
      slot: CosmeticSlot.gunslinger,
      cost: 900,
      primary: Color(0xFF7A3B2E),
      secondary: Color(0xFFFF7A3D),
    ),
    // ---- Legendary gunslinger ----
    Cosmetic(
      id: 'skin_revenant',
      name: 'Revenant',
      blurb: 'Cold spectral fire. They say it was already dead.',
      slot: CosmeticSlot.gunslinger,
      cost: 2800,
      primary: Color(0xFF0B2B2B),
      secondary: Color(0xFF5CFFE1),
    ),

    // Arena themes (primary = grid, secondary = wall accent).
    Cosmetic(
      id: 'theme_default',
      name: 'Midnight',
      blurb: 'The deep neon-blue arena.',
      slot: CosmeticSlot.arenaTheme,
      cost: 0,
      primary: AppColors.blue700,
      secondary: AppColors.blue400,
    ),
    Cosmetic(
      id: 'theme_dust',
      name: 'Dust Bowl',
      blurb: 'Sun-baked amber grid lines.',
      slot: CosmeticSlot.arenaTheme,
      cost: 300,
      primary: AppColors.amber700,
      secondary: AppColors.amber400,
    ),
    Cosmetic(
      id: 'theme_verdant',
      name: 'Verdant',
      blurb: 'A toxic-green frontier.',
      slot: CosmeticSlot.arenaTheme,
      cost: 300,
      primary: Color(0xFF1F6B45),
      secondary: AppColors.success,
    ),
    Cosmetic(
      id: 'theme_crimson',
      name: 'Crimson Mesa',
      blurb: 'Bloodred canyon glow.',
      slot: CosmeticSlot.arenaTheme,
      cost: 350,
      primary: Color(0xFF7A2230),
      secondary: AppColors.error,
    ),
    Cosmetic(
      id: 'theme_glacier',
      name: 'Glacier',
      blurb: 'Pale blue ice, lit from under the floor.',
      slot: CosmeticSlot.arenaTheme,
      cost: 500,
      primary: Color(0xFF2C5A73),
      secondary: Color(0xFF9FE8FF),
    ),
    Cosmetic(
      id: 'theme_saloon',
      name: 'Last Saloon',
      blurb: 'Warm lamplight on old stained timber.',
      slot: CosmeticSlot.arenaTheme,
      cost: 650,
      primary: Color(0xFF6B4423),
      secondary: Color(0xFFFFC97A),
    ),
    Cosmetic(
      id: 'theme_voidwalk',
      name: 'Voidwalk',
      blurb: 'Deep violet nothing with a magenta horizon.',
      slot: CosmeticSlot.arenaTheme,
      cost: 950,
      primary: Color(0xFF2A1245),
      secondary: Color(0xFFFF5CE1),
    ),
    // ---- Legendary arena ----
    Cosmetic(
      id: 'theme_goldrush',
      name: 'Gold Rush',
      blurb: 'The whole arena cast in struck gold. Loud on purpose.',
      slot: CosmeticSlot.arenaTheme,
      cost: 3200,
      primary: Color(0xFF7A5A12),
      secondary: Color(0xFFFFD866),
    ),
  ];

  static Cosmetic byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => trailDefault);

  static List<Cosmetic> forSlot(CosmeticSlot slot) =>
      all.where((c) => c.slot == slot).toList();

  /// The free stock cosmetic for a slot (the equipped fallback).
  static Cosmetic defaultFor(CosmeticSlot slot) =>
      all.firstWhere((c) => c.slot == slot && c.isFree);
}
