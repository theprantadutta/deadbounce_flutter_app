import 'dart:math';

import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_outbox_writer.dart';
import 'package:deadbounce_flutter_app/features/economy/data/repositories/wallet_repository_impl.dart';
import 'package:deadbounce_flutter_app/features/economy/domain/entities/coin_transaction.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late WalletRepositoryImpl wallet;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    wallet = WalletRepositoryImpl(
      db: db,
      outboxWriter: SyncOutboxWriter(db),
    );
  });

  tearDown(() => db.close());

  test('cached balance equals SUM(ledger) after randomized transactions',
      () async {
    final rng = Random(42);
    var expected = 0;

    for (var i = 0; i < 200; i++) {
      final amount = rng.nextInt(500) - 100; // skewed positive, some spends
      if (amount == 0) continue;
      expected += amount;
      await wallet.addTransaction(
        amount: amount,
        reason: CoinReason.values[rng.nextInt(CoinReason.values.length)],
      );
    }

    expect(await wallet.getBalance(), expected);
    expect(await db.coinLedgerDao.deriveBalance(), expected);
  });

  test('every ledger transaction enqueues exactly one outbox event with '
      'the transaction id as event id', () async {
    final txn = await wallet.addTransaction(
      amount: 120,
      reason: CoinReason.dailyLogin,
    );

    final outbox = await db.select(db.syncOutbox).get();
    expect(outbox, hasLength(1));
    expect(outbox.single.id, txn.id);
    expect(outbox.single.entityType, 'coinTxn');
    expect(outbox.single.status, 'pending');
  });

  test('balance starts at zero with an empty ledger', () async {
    expect(await wallet.getBalance(), 0);
    expect(await db.coinLedgerDao.deriveBalance(), 0);
  });
}
