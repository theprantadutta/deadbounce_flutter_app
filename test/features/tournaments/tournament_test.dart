import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/core/storage/token_storage.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_outbox_writer.dart';
import 'package:deadbounce_flutter_app/features/tournaments/domain/repositories/tournament_repository.dart';
import 'package:deadbounce_flutter_app/features/game/engine/waves/wave_definition.dart';
import 'package:deadbounce_flutter_app/features/tournaments/data/repositories/tournament_repository_impl.dart';
import 'package:deadbounce_flutter_app/features/tournaments/data/datasources/tournament_api.dart';
import 'package:deadbounce_flutter_app/features/tournaments/domain/entities/tournament.dart';
import 'package:deadbounce_flutter_app/core/network/api_client.dart';
import 'package:drift/native.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

Tournament _tournament({
  String id = 't1',
  String configJson = '{}',
  TournamentState state = TournamentState.active,
  bool joined = false,
  int? rank,
  int? rewardCoins,
  bool rewardClaimed = false,
}) =>
    Tournament(
      id: id,
      cadence: TournamentCadence.daily,
      state: state,
      name: 'TEST CUP',
      tagline: 'tagline',
      startsAt: DateTime.utc(2026, 6, 19),
      endsAt: DateTime.utc(2026, 6, 20),
      seed: 42,
      configJson: configJson,
      entryFeeCoins: 100,
      rewardTableJson: '{"1":1500,"2":800}',
      joined: joined,
      paid: false,
      bestScore: 0,
      rank: rank,
      rewardCoins: rewardCoins,
      rewardClaimed: rewardClaimed,
    );

/// A TournamentApi that never reaches the network — its methods throw so we
/// can drive the offline/local paths.
class _OfflineApi extends TournamentApi {
  _OfflineApi() : super(_unusedClient);
  static final ApiClient _unusedClient = ApiClient(_NoTokenStorage());
  @override
  Future<List<TournamentDto>> list() async =>
      throw ApiException('offline', statusCode: null);
}

class _NoTokenStorage extends TokenStorage {
  @override
  Future<String?> readAccessToken() async => null;
}

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: 'API_BASE_URL_DEV=http://localhost');
  });

  group('Tournament.toChallengeConfig', () {
    test('maps the server ruleset onto the engine config', () {
      final t = _tournament(
        configJson: '{"forced_enemy_type":"charger","starting_hearts":1,'
            '"score_multiplier":3.0,"extra_wall_damage":2,"random_upgrades":true}',
      );
      final c = t.toChallengeConfig();
      expect(c.forcedEnemyType, EnemyType.charger);
      expect(c.startingHearts, 1);
      expect(c.scoreMultiplier, 3.0);
      expect(c.extraWallDamage, 2);
      expect(c.randomUpgrades, isTrue);
    });

    test('defaults gracefully on empty/garbage config', () {
      expect(_tournament(configJson: '{}').toChallengeConfig().scoreMultiplier, 1);
      final garbage = _tournament(configJson: 'not json').toChallengeConfig();
      expect(garbage.forcedEnemyType, isNull);
      expect(garbage.scoreMultiplier, 1);
    });

    test('topReward reads rank 1 from the reward table', () {
      expect(_tournament().topReward, 1500);
    });

    test('hasUnclaimedReward only when ended with an unclaimed payout', () {
      expect(
        _tournament(state: TournamentState.ended, rewardCoins: 800).hasUnclaimedReward,
        isTrue,
      );
      expect(
        _tournament(state: TournamentState.ended, rewardCoins: 800, rewardClaimed: true)
            .hasUnclaimedReward,
        isFalse,
      );
      expect(_tournament(rewardCoins: 800).hasUnclaimedReward, isFalse); // active
    });
  });

  group('TournamentRepositoryImpl (local paths)', () {
    late AppDatabase db;
    late TournamentRepositoryImpl repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = TournamentRepositoryImpl(
        db: db,
        api: _OfflineApi(),
        outboxWriter: SyncOutboxWriter(db),
      );
    });
    tearDown(() => db.close());

    Future<void> seedCoins(int amount) =>
        db.coinLedgerDao.insertTransaction(CoinLedgerRow(
          id: 'seed',
          amount: amount,
          reason: 'adjustment',
          runId: null,
          createdAt: 1,
        ));

    Future<void> cacheOne({int fee = 100}) => db.tournamentDao.cacheList([
          TournamentRow(
            id: 't1',
            cadence: 'daily',
            state: 'active',
            name: 'TEST CUP',
            tagline: 'tag',
            startsAt: 1,
            endsAt: 9999999999999,
            seed: 42,
            configJson: '{}',
            entryFeeCoins: fee,
            rewardTableJson: '{"1":1500}',
            joined: false,
            paid: false,
            bestScore: 0,
            rank: null,
            rewardCoins: null,
            rewardClaimed: false,
            lastSyncedAt: 1,
          ),
        ]);

    test('join rejects when the player cannot afford the fee', () async {
      await cacheOne(fee: 500);
      await seedCoins(100);
      await expectLater(
        repo.join('t1'),
        throwsA(isA<TournamentException>()),
      );
      // No spend happened.
      expect(await db.coinLedgerDao.getBalance(), 100);
    });

    test('claimReward writes a positive coinTxn and marks claimed', () async {
      await cacheOne();
      await seedCoins(0);
      final t = _tournament(
        state: TournamentState.ended,
        joined: true,
        rank: 1,
        rewardCoins: 1500,
      );
      await repo.claimReward(t);

      expect(await db.coinLedgerDao.getBalance(), 1500);
      final ledger = await db.coinLedgerDao.recentTransactions();
      expect(
        ledger.any((r) => r.reason == 'tournamentReward' && r.amount == 1500),
        isTrue,
      );
      final outbox = await db.select(db.syncOutbox).get();
      expect(outbox.any((e) => e.entityType == 'coinTxn'), isTrue);
      final row = await db.tournamentDao.getById('t1');
      expect(row!.rewardClaimed, isTrue);
    });
  });
}
