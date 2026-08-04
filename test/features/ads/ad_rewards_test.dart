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
    wallet = WalletRepositoryImpl(db: db, outboxWriter: SyncOutboxWriter(db));
  });

  tearDown(() => db.close());

  group('ad reward coins are mirrored, never synced', () {
    // The backend REJECTS the adReward reason over the sync channel — a client
    // that could mint ad coins would get paid for ads nobody watched. So the
    // local entry exists purely for display and must carry no outbox event.
    test('credits locally with no outbox event', () async {
      await wallet.creditServerGranted(
        id: 'ad:txn-1',
        amount: 600,
        reason: CoinReason.adReward,
      );

      expect(await db.coinLedgerDao.getBalance(), 600);
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    });

    test('a replayed transaction id collides instead of paying twice',
        () async {
      await wallet.creditServerGranted(
        id: 'ad:txn-1',
        amount: 600,
        reason: CoinReason.adReward,
      );

      // Happens whenever an acknowledge is lost: the server replays the same
      // reward on the next sync, and the client must not credit it again.
      await expectLater(
        wallet.creditServerGranted(
          id: 'ad:txn-1',
          amount: 600,
          reason: CoinReason.adReward,
        ),
        throwsA(anything),
      );

      expect(await db.coinLedgerDao.getBalance(), 600);
    });

    test('distinct transactions each credit once', () async {
      await wallet.creditServerGranted(
        id: 'ad:txn-1',
        amount: 600,
        reason: CoinReason.adReward,
      );
      await wallet.creditServerGranted(
        id: 'ad:txn-2',
        amount: 250,
        reason: CoinReason.adReward,
      );

      expect(await db.coinLedgerDao.getBalance(), 850);
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    });

    test('the ledger id is namespaced, so an ad and an IAP cannot collide',
        () async {
      // Both derive their id from an external identifier; without distinct
      // prefixes a shared token value would silently swallow one of them.
      await wallet.creditServerGranted(
        id: 'ad:shared-id',
        amount: 600,
        reason: CoinReason.adReward,
      );
      await wallet.creditServerGranted(
        id: 'iap:shared-id',
        amount: 1000,
        reason: CoinReason.iapCoinPack,
      );

      expect(await db.coinLedgerDao.getBalance(), 1600);
    });
  });
}
