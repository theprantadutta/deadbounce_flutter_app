import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/sync/sync_event.dart';
import '../../../../core/sync/sync_outbox_writer.dart';
import '../../../economy/domain/entities/coin_transaction.dart';
import '../../domain/meta_catalog.dart';
import '../../domain/repositories/meta_repository.dart';

class MetaRepositoryImpl implements MetaRepository {
  MetaRepositoryImpl({
    required this._db,
    required this._outboxWriter,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SyncOutboxWriter _outboxWriter;
  final Uuid _uuid;

  @override
  Stream<Map<String, int>> watchOwnedLevels() => _db.metaUpgradesDao
      .watchOwned()
      .map((rows) => {for (final r in rows) r.perkId: r.level});

  @override
  Future<Map<String, int>> ownedLevels() async {
    final rows = await _db.metaUpgradesDao.getOwned();
    return {for (final r in rows) r.perkId: r.level};
  }

  @override
  Future<void> purchase(MetaPerk perk) async {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

    // Coin spend (ledger + outbox) and the level bump commit together.
    await _db.transaction(() async {
      final current = await _db.metaUpgradesDao.levelOf(perk.id);
      if (current >= perk.maxLevel) {
        throw const MetaPurchaseException('Already at the highest tier.');
      }
      final cost = perk.costForLevel(current);
      final balance = await _db.coinLedgerDao.getBalance();
      if (balance < cost) {
        throw const MetaPurchaseException('Not enough coins, partner.');
      }

      final txnId = _uuid.v4();
      await _db.coinLedgerDao.insertTransaction(CoinLedgerRow(
        id: txnId,
        amount: -cost,
        reason: CoinReason.shopPurchase.name,
        runId: null,
        createdAt: nowMs,
      ));
      await _outboxWriter.enqueue(
        SyncEntityType.coinTxn,
        {
          'txn_id': txnId,
          'amount': -cost,
          'reason': CoinReason.shopPurchase.name,
          'run_id': null,
          'created_at': DateTime.fromMillisecondsSinceEpoch(nowMs, isUtc: true)
              .toIso8601String(),
        },
        eventId: txnId,
      );
      await _db.metaUpgradesDao.setLevel(perk.id, current + 1, nowMs);
    });

    AppLogger.talker.info('[meta] purchased ${perk.id}');
  }
}
