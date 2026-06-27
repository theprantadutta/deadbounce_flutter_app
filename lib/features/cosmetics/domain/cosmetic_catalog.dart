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
  });

  final String id;
  final String name;
  final String blurb;
  final CosmeticSlot slot;
  final int cost;
  final Color primary;
  final Color secondary;

  bool get isFree => cost == 0;
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
  ];

  static Cosmetic byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => trailDefault);

  static List<Cosmetic> forSlot(CosmeticSlot slot) =>
      all.where((c) => c.slot == slot).toList();

  /// The free stock cosmetic for a slot (the equipped fallback).
  static Cosmetic defaultFor(CosmeticSlot slot) =>
      all.firstWhere((c) => c.slot == slot && c.isFree);
}
