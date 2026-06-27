import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// total_coins_earned is folded centrally by CoinLedgerDao.insertTransaction —
/// every positive entry except the snapshot seed — so the lifetime stat counts
/// all earning sources (runs, login, achievements, tournaments), matching the
/// backend, instead of run coins only.
void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> earned() async =>
      (await db.statsDao.getStats())?.totalCoinsEarned ?? 0;

  CoinLedgerRow row(int amount, String reason) => CoinLedgerRow(
        id: '$reason:$amount',
        amount: amount,
        reason: reason,
        runId: null,
        createdAt: 1,
      );

  test('positive entries from any source fold into total_coins_earned',
      () async {
    await db.coinLedgerDao.insertTransaction(row(100, 'runReward'));
    await db.coinLedgerDao.insertTransaction(row(50, 'dailyLogin'));
    await db.coinLedgerDao.insertTransaction(row(10, 'achievementClaim'));
    await db.coinLedgerDao.insertTransaction(row(800, 'tournamentReward'));
    expect(await earned(), 960);
    expect(await db.coinLedgerDao.getBalance(), 960);
  });

  test('spends do not count as earned', () async {
    await db.coinLedgerDao.insertTransaction(row(100, 'runReward'));
    await db.coinLedgerDao.insertTransaction(row(-30, 'shopPurchase'));
    expect(await earned(), 100); // unchanged by the spend
    expect(await db.coinLedgerDao.getBalance(), 70);
  });

  test('the snapshotRestore balance seed does NOT double-count earned',
      () async {
    // The snapshot restores total_coins_earned directly, so its balance-seed
    // ledger entry must not also bump it.
    await db.coinLedgerDao.insertTransaction(row(5000, 'snapshotRestore'));
    expect(await earned(), 0);
    expect(await db.coinLedgerDao.getBalance(), 5000);
  });
}
