import '../cosmetic_catalog.dart';
import '../cosmetic_loadout.dart';

/// Owned + equipped cosmetics. Purchases spend through the coin ledger
/// (synced); ownership + equip sync as a `cosmeticState` aggregate.
abstract interface class CosmeticsRepository {
  /// Set of owned cosmetic ids (free defaults are always considered owned).
  Stream<Set<String>> watchOwned();

  /// Equipped cosmetic id per slot (absent slot = stock default).
  Stream<Map<CosmeticSlot, String>> watchEquipped();

  /// The resolved loadout right now (for run start).
  Future<CosmeticLoadout> loadout();

  /// Buys [cosmetic] (coin spend + ownership, atomically). Throws
  /// [CosmeticPurchaseException] if already owned or unaffordable.
  Future<void> purchase(Cosmetic cosmetic);

  /// Equips [cosmetic] into its slot (must be owned).
  Future<void> equip(Cosmetic cosmetic);
}

class CosmeticPurchaseException implements Exception {
  const CosmeticPurchaseException(this.message);
  final String message;

  @override
  String toString() => 'CosmeticPurchaseException: $message';
}
