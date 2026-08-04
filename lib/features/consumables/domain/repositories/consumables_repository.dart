import '../consumable_catalog.dart';
import '../consumable_loadout.dart';

/// Raised when a purchase can't go through, carrying a message for the player.
class ConsumablePurchaseException implements Exception {
  const ConsumablePurchaseException(this.message);

  final String message;

  @override
  String toString() => 'ConsumablePurchaseException: $message';
}

abstract interface class ConsumablesRepository {
  /// Held count per item id. Live, so the picker updates as stock changes.
  Stream<Map<String, int>> watchStock();

  Future<Map<String, int>> stock();

  /// Buys one [item]: spends coins through the ledger and increments stock, in
  /// one transaction. Throws [ConsumablePurchaseException] when unaffordable or
  /// already at the stack cap.
  Future<void> buy(Consumable item);

  /// Spends one of each id in [itemIds] and returns their combined effect.
  ///
  /// Consumption happens at RUN START, not run end — the player committed the
  /// moment the run began, and tying it to the end would let someone quit out
  /// to keep the item after seeing a bad opening.
  ///
  /// Ids the player doesn't actually hold are skipped rather than throwing, so
  /// a stale picker selection can never block a run from starting.
  Future<ConsumableLoadout> consume(Iterable<String> itemIds);

  /// The loadout the player last rode out with.
  ///
  /// Exists so the picker opens pre-ticked and a retry keeps the same kit —
  /// re-choosing an identical loadout before every run is the tax that makes a
  /// pre-run screen feel like a door rather than a decision.
  ///
  /// Filtered to what is still in stock, so an item that ran out silently drops
  /// off instead of being offered and then skipped.
  Future<List<String>> lastSelection();

  Future<void> saveSelection(List<String> itemIds);
}
