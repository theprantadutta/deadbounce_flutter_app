import 'cosmetic_catalog.dart';

/// The resolved cosmetics for one run — read once at run start (like the
/// meta loadout / game feel) and handed to the game. Visual only.
class CosmeticLoadout {
  const CosmeticLoadout({
    required this.bulletTrail,
    required this.gunslinger,
    required this.arenaTheme,
  });

  final Cosmetic bulletTrail;
  final Cosmetic gunslinger;
  final Cosmetic arenaTheme;

  /// Resolves equipped ids (slot → id) to cosmetics, falling back to the free
  /// stock look for any unset/invalid slot.
  factory CosmeticLoadout.fromEquipped(Map<CosmeticSlot, String> equipped) {
    Cosmetic resolve(CosmeticSlot slot) {
      final id = equipped[slot];
      if (id == null) return CosmeticCatalog.defaultFor(slot);
      final c = CosmeticCatalog.byId(id);
      return c.slot == slot ? c : CosmeticCatalog.defaultFor(slot);
    }

    return CosmeticLoadout(
      bulletTrail: resolve(CosmeticSlot.bulletTrail),
      gunslinger: resolve(CosmeticSlot.gunslinger),
      arenaTheme: resolve(CosmeticSlot.arenaTheme),
    );
  }

  /// All-defaults loadout (used by daily challenges/tournaments and as a
  /// safe fallback). Looks identical to the original game.
  static final CosmeticLoadout stock =
      CosmeticLoadout.fromEquipped(const {});
}
