import '../meta_catalog.dart';

/// Owned permanent upgrades + purchasing. Spending goes through the coin
/// ledger (synced); ownership is local for now.
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
