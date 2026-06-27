import '../meta_catalog.dart';

/// Owned permanent upgrades + purchasing. Both the coin spend (ledger, as a
/// `shopPurchase` coinTxn) and the owned-levels aggregate (as a `metaState`
/// event) sync via the outbox, and ownership is restored from the snapshot on
/// reinstall. Reads are local-first (Drift), so purchasing works offline.
abstract interface class MetaRepository {
  /// perkId → owned level (absent = level 0).
  Stream<Map<String, int>> watchOwnedLevels();
  Future<Map<String, int>> ownedLevels();

  /// Buys the next level of [perk] (coin spend + level bump, atomically).
  /// Throws [MetaPurchaseException] if maxed or unaffordable.
  Future<void> purchase(MetaPerk perk);
}

class MetaPurchaseException implements Exception {
  const MetaPurchaseException(this.message);
  final String message;

  @override
  String toString() => 'MetaPurchaseException: $message';
}
