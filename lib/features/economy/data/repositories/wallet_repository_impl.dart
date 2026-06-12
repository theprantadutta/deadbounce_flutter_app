import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/sync/sync_event.dart';
import '../../../../core/sync/sync_outbox_writer.dart';
import '../../domain/entities/coin_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl({
    required this._db,
    required this._outboxWriter,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SyncOutboxWriter _outboxWriter;
  final Uuid _uuid;

  @override
  Stream<int> watchBalance() => _db.coinLedgerDao.watchBalance();

  @override
  Future<int> getBalance() => _db.coinLedgerDao.getBalance();

  @override
  Future<CoinTransaction> addTransaction({
    required int amount,
    required CoinReason reason,
    String? runId,
  }) async {
    final txn = CoinTransaction(
      id: _uuid.v4(),
      amount: amount,
      reason: reason,
      createdAt: DateTime.now().toUtc(),
      runId: runId,
    );

    await _db.transaction(() async {
      await _db.coinLedgerDao.insertTransaction(_toRow(txn));
      // The ledger row id doubles as the sync idempotency key.
      await _outboxWriter.enqueue(
        SyncEntityType.coinTxn,
        _toSyncPayload(txn),
        eventId: txn.id,
      );
    });

    return txn;
  }

  @override
  Future<List<CoinTransaction>> recentTransactions({int limit = 50}) async {
    final rows = await _db.coinLedgerDao.recentTransactions(limit: limit);
    return rows.map(_fromRow).toList();
  }

  static CoinLedgerRow _toRow(CoinTransaction t) => CoinLedgerRow(
        id: t.id,
        amount: t.amount,
        reason: t.reason.name,
        runId: t.runId,
        createdAt: t.createdAt.millisecondsSinceEpoch,
      );

  static CoinTransaction _fromRow(CoinLedgerRow r) => CoinTransaction(
        id: r.id,
        amount: r.amount,
        reason: CoinReason.values.asNameMap()[r.reason] ?? CoinReason.adjustment,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true),
        runId: r.runId,
      );

  static Map<String, dynamic> _toSyncPayload(CoinTransaction t) => {
        'txn_id': t.id,
        'amount': t.amount,
        'reason': t.reason.name,
        'run_id': t.runId,
        'created_at': t.createdAt.toIso8601String(),
      };
}
