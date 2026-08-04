import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/sync/sync_event.dart';
import '../../../../core/sync/sync_outbox_writer.dart';
import '../../../economy/domain/entities/coin_transaction.dart';
import '../../domain/consumable_catalog.dart';
import '../../domain/consumable_loadout.dart';
import '../../domain/repositories/consumables_repository.dart';

class ConsumablesRepositoryImpl implements ConsumablesRepository {
  ConsumablesRepositoryImpl({
    required this._db,
    required this._outboxWriter,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SyncOutboxWriter _outboxWriter;
  final Uuid _uuid;

  @override
  Stream<Map<String, int>> watchStock() => _db.consumablesDao
      .watchStock()
      .map((rows) => {for (final r in rows) r.itemId: r.count});

  @override
  Future<Map<String, int>> stock() async {
    final rows = await _db.consumablesDao.getStock();
    return {for (final r in rows) r.itemId: r.count};
  }

  @override
  Future<void> buy(Consumable item) async {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

    // Coin spend (ledger + outbox), the stock bump, and the stock aggregate
    // all commit together — the offline-first invariant. A spend without the
    // stock would be taking coins for nothing.
    await _db.transaction(() async {
      final held = await _db.consumablesDao.countOf(item.id);
      if (held >= ConsumableCatalog.maxStack) {
        throw const ConsumablePurchaseException(
          "You're carrying all you can of those.",
        );
      }

      final balance = await _db.coinLedgerDao.getBalance();
      if (balance < item.cost) {
        throw const ConsumablePurchaseException('Not enough coins, partner.');
      }

      final txnId = _uuid.v4();
      await _db.coinLedgerDao.insertTransaction(CoinLedgerRow(
        id: txnId,
        amount: -item.cost,
        reason: CoinReason.shopPurchase.name,
        runId: null,
        createdAt: nowMs,
      ));
      await _outboxWriter.enqueue(
        SyncEntityType.coinTxn,
        {
          'txn_id': txnId,
          'amount': -item.cost,
          'reason': CoinReason.shopPurchase.name,
          'run_id': null,
          'created_at': DateTime.fromMillisecondsSinceEpoch(nowMs, isUtc: true)
              .toIso8601String(),
        },
        eventId: txnId,
      );

      await _db.consumablesDao.setCount(item.id, held + 1, nowMs);
      await _enqueueState(nowMs);
    });

    AppLogger.talker.info('[consumables] bought ${item.id}');
  }

  @override
  Future<ConsumableLoadout> consume(Iterable<String> itemIds) async {
    // Deduplicated: one of each per run. Taking two Field Dressings would be a
    // second heart, which the picker doesn't offer and the effect fold
    // wouldn't express anyway.
    final wanted = itemIds.toSet();
    if (wanted.isEmpty) return ConsumableLoadout.empty;

    final spent = <String>[];
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

    await _db.transaction(() async {
      for (final id in wanted) {
        if (!ConsumableCatalog.isKnown(id)) continue;
        final held = await _db.consumablesDao.countOf(id);
        // Silently skip what isn't held: a stale picker selection must never
        // stop a run from starting.
        if (held <= 0) continue;
        await _db.consumablesDao.setCount(id, held - 1, nowMs);
        spent.add(id);
      }
      if (spent.isNotEmpty) await _enqueueState(nowMs);
    });

    if (spent.isNotEmpty) {
      AppLogger.talker.info('[consumables] consumed ${spent.join(', ')}');
    }
    return ConsumableLoadout.fromIds(spent);
  }

  /// Enqueues the full stock aggregate (last-writer-wins server-side),
  /// mirroring MetaRepositoryImpl / CosmeticsRepositoryImpl. The coin spend
  /// rides its own coinTxn; this carries the STOCK so paid items survive a
  /// reinstall.
  ///
  /// Must be called INSIDE the caller's transaction so the outbox row can't
  /// commit without the stock change it describes.
  Future<void> _enqueueState(int nowMs) async {
    final rows = await _db.consumablesDao.getStock();
    await _outboxWriter.enqueue(
      SyncEntityType.consumableState,
      {
        // Zero counts are sent too: the server replaces the whole aggregate,
        // so omitting them would look identical to "unchanged" rather than
        // "spent down to none".
        'stock': {for (final r in rows) r.itemId: r.count},
        'updated_at': nowMs,
      },
    );
  }
}
