import 'package:deadbounce_flutter_app/features/game/engine/combat/bullet_state.dart';
import 'package:deadbounce_flutter_app/features/game/engine/combat/bullet_stats.dart';
import 'package:deadbounce_flutter_app/features/game/engine/game_rng.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import 'package:deadbounce_flutter_app/features/game/engine/physics/wall_segment.dart';
import 'package:deadbounce_flutter_app/features/game/engine/upgrades/run_modifiers.dart';
import 'package:deadbounce_flutter_app/features/game/engine/upgrades/upgrade_card.dart';
import 'package:deadbounce_flutter_app/features/game/engine/upgrades/upgrade_catalog.dart';
import 'package:deadbounce_flutter_app/features/game/engine/upgrades/upgrade_deck.dart';
import 'package:deadbounce_flutter_app/features/game/engine/upgrades/upgrade_modifier.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeWorldOps implements GameWorldOps {
  FakeWorldOps(this.rng);

  final spawnedBullets = <(BulletState, BulletStats)>[];
  final fireTrails = <Vector2>[];
  Vector2? nearestEnemy;

  @override
  final GameRng rng;

  @override
  void spawnBullet(
    BulletState state,
    BulletStats stats, {
    double delaySeconds = 0,
  }) => spawnedBullets.add((state, stats));

  @override
  void spawnFireTrail(
    Vector2 position,
    double radius,
    double duration,
    int damagePerSecond,
  ) => fireTrails.add(position);

  @override
  Vector2? nearestEnemyTo(Vector2 position, {required double within}) =>
      nearestEnemy;
}

void main() {
  late FakeWorldOps world;
  late RunModifiers mods;

  setUp(() {
    GameBalance.I.resetToDefaults();
    world = FakeWorldOps(GameRng(42));
    mods = RunModifiers();
  });

  void pick(String id) => mods.add(UpgradeCatalog.byId(id));

  test('stat folds compose: Quickdraw x2 + Heavy Caliber + Rubber Walls', () {
    pick('quickdraw');
    pick('quickdraw');
    pick('heavy_caliber');
    pick('rubber_walls');

    final player = mods.effectivePlayerStats();
    expect(
      player.fireCooldown,
      closeTo(GameBalance.I.player.fireCooldown * 0.78 * 0.78, 1e-9),
    );

    final bullet = mods.effectiveBulletStats();
    expect(bullet.radius, closeTo(GameBalance.I.bullet.radius * 1.4, 1e-9));
    expect(bullet.damagePerBounce, 2);
  });

  test('Split Shot fires exactly once per bullet at bounce 3', () {
    pick('split_shot');
    final state = BulletState(
      position: Vector2(100, 100),
      velocity: Vector2(500, 0),
    );
    final wall = WallSegment(
      a: Vector2(200, 0),
      b: Vector2(200, 400),
      normal: Vector2(-1, 0),
    );

    BounceContext ctx(int index) => BounceContext(
      bullet: state,
      stats: BulletStats.base(),
      wall: wall,
      bounceIndex: index,
      world: world,
    );

    mods.bounce(ctx(1));
    mods.bounce(ctx(2));
    expect(world.spawnedBullets, isEmpty);

    mods.bounce(ctx(3));
    expect(world.spawnedBullets, hasLength(1));
    expect(
      world.spawnedBullets.single.$1.bounces,
      state.bounces,
      reason: 'clone inherits bounce count (already lethal)',
    );

    // Same bullet, later bounce 3 contexts: never splits again.
    mods.bounce(ctx(3));
    expect(world.spawnedBullets, hasLength(1));
    // Clones are flagged so they cannot split either.
    expect(world.spawnedBullets.single.$1.flags.hasSplit, isTrue);
  });

  test('Ghost Round charges every 4th shot', () {
    pick('ghost_round');

    List<PendingShot> fire(int shotIndex) {
      final shots = [PendingShot(direction: Vector2(0, -1), speed: 600)];
      mods.fire(
        FireContext(
          origin: Vector2.zero(),
          shotIndex: shotIndex,
          shots: shots,
          world: world,
        ),
      );
      return shots;
    }

    expect(fire(1).single.flags.ghostPassesRemaining, 0);
    expect(fire(3).single.flags.ghostPassesRemaining, 0);
    expect(fire(4).single.flags.ghostPassesRemaining, 1);
    expect(fire(8).single.flags.ghostPassesRemaining, 1);
  });

  test('Last Stand prevents exactly one death', () {
    pick('last_stand');

    final fatal1 = PlayerDamageContext(heartsAfter: 0);
    mods.playerDamaged(fatal1);
    expect(fatal1.deathPrevented, isTrue);

    final fatal2 = PlayerDamageContext(heartsAfter: 0);
    mods.playerDamaged(fatal2);
    expect(fatal2.deathPrevented, isFalse);
  });

  test('Last Stand ignores non-fatal hits', () {
    pick('last_stand');
    final hit = PlayerDamageContext(heartsAfter: 1);
    mods.playerDamaged(hit);
    expect(hit.deathPrevented, isFalse);
    // Still armed for the real fatal hit.
    final fatal = PlayerDamageContext(heartsAfter: 0);
    mods.playerDamaged(fatal);
    expect(fatal.deathPrevented, isTrue);
  });

  test('Echo Shot duplicates ~10% of shots over many seeded rolls', () {
    pick('echo_shot');
    var duplicates = 0;
    for (var i = 0; i < 10000; i++) {
      final shots = [PendingShot(direction: Vector2(0, -1), speed: 600)];
      mods.fire(
        FireContext(
          origin: Vector2.zero(),
          shotIndex: i,
          shots: shots,
          world: world,
        ),
      );
      if (shots.length > 1) duplicates++;
    }
    expect(duplicates, inInclusiveRange(800, 1200));
  });

  test('Coin Magnet multiplies coin amounts per stack', () {
    pick('coin_magnet');
    pick('coin_magnet');
    final ctx = CoinContext(100);
    mods.coinEarned(ctx);
    expect(ctx.amount, closeTo(100 * 1.25 * 1.25, 1e-9));
  });

  test('Magnet Rounds only steers after bounce 2 and preserves speed', () {
    pick('magnet_rounds');
    world.nearestEnemy = Vector2(0, 0);

    final straight = BulletState(
      position: Vector2(100, 100),
      velocity: Vector2(500, 0),
    );
    mods.bulletUpdate(
      BulletUpdateContext(
        bullet: straight,
        stats: BulletStats.base(),
        world: world,
      ),
      1 / 60,
    );
    expect(straight.velocity.x, 500, reason: 'no homing before bounce 2');

    straight.bounces = 2;
    final speedBefore = straight.velocity.length;
    mods.bulletUpdate(
      BulletUpdateContext(
        bullet: straight,
        stats: BulletStats.base(),
        world: world,
      ),
      1 / 60,
    );
    expect(straight.velocity.length, closeTo(speedBefore, 1e-3));
    expect(
      straight.velocity.x,
      lessThan(500),
      reason: 'velocity rotated toward the enemy',
    );
  });

  test('deck draws 3 distinct cards and respects maxStacks', () {
    final rng = GameRng(5);

    final draw = UpgradeDeck.draw3(rng, mods);
    expect(draw, hasLength(3));
    expect(draw.map((c) => c.id).toSet(), hasLength(3));

    // Max out split_shot (maxStacks 1) — it must never appear again.
    pick('split_shot');
    for (var i = 0; i < 200; i++) {
      final cards = UpgradeDeck.draw3(rng, mods);
      expect(cards.any((c) => c.id == 'split_shot'), isFalse);
    }
  });

  test('rarity weighting favors commons over epics across many draws', () {
    final rng = GameRng(11);
    var commons = 0;
    var epics = 0;
    for (var i = 0; i < 2000; i++) {
      for (final card in UpgradeDeck.draw3(rng, RunModifiers())) {
        switch (card.rarity) {
          case UpgradeRarity.common:
            commons++;
          case UpgradeRarity.epic:
            epics++;
          case UpgradeRarity.rare:
            break;
        }
      }
    }
    expect(commons, greaterThan(epics * 2));
  });

  group('new upgrade cards', () {
    test('Long Fuse / Greased Lead / Rifling fold onto bullet stats', () {
      pick('long_fuse');
      pick('rifling');
      pick('greased_lead');
      final b = mods.effectiveBulletStats();
      expect(b.lifetime, closeTo(GameBalance.I.bullet.lifetime + 1.2, 1e-9));
      expect(b.maxBounces, GameBalance.I.bullet.maxBounces + 2);
      expect(b.speedGainPerBounce,
          closeTo(GameBalance.I.bullet.speedGainPerBounce + 0.03, 1e-9));
    });

    test('Fan Fire turns one shot into three', () {
      pick('fan_fire');
      final shots = [PendingShot(direction: Vector2(0, -1), speed: 600)];
      mods.fire(FireContext(
          origin: Vector2.zero(), shotIndex: 1, shots: shots, world: world));
      expect(shots, hasLength(3));
    });

    test('Vengeance arms on a survived hit, spends on the next shot only', () {
      pick('vengeance');
      List<PendingShot> fireOnce(int i) {
        final shots = [PendingShot(direction: Vector2(0, -1), speed: 600)];
        mods.fire(FireContext(
            origin: Vector2.zero(), shotIndex: i, shots: shots, world: world));
        return shots;
      }

      expect(fireOnce(1), hasLength(1), reason: 'no charge yet');
      mods.playerDamaged(PlayerDamageContext(heartsAfter: 2)); // survived
      expect(fireOnce(2), hasLength(3), reason: 'retaliation burst');
      expect(fireOnce(3), hasLength(1), reason: 'charge consumed');

      // A fatal hit never arms it.
      mods.playerDamaged(PlayerDamageContext(heartsAfter: 0));
      expect(fireOnce(4), hasLength(1));
    });

    test('Flashpoint bursts once, at bounce 4', () {
      pick('flashpoint');
      final state =
          BulletState(position: Vector2(50, 50), velocity: Vector2(200, 0));
      final wall = WallSegment(
          a: Vector2(0, 0), b: Vector2(0, 400), normal: Vector2(1, 0));
      BounceContext ctx(int i) => BounceContext(
          bullet: state,
          stats: BulletStats.base(),
          wall: wall,
          bounceIndex: i,
          world: world);

      mods.bounce(ctx(3));
      expect(world.fireTrails, isEmpty);
      mods.bounce(ctx(4));
      expect(world.fireTrails, hasLength(1));
      mods.bounce(ctx(5));
      expect(world.fireTrails, hasLength(1), reason: 'one flash per bullet');
    });

    KillContext killCtx(BulletState b, int chain) => KillContext(
        bullet: b,
        enemyType: 'drifter',
        chainLength: chain,
        position: b.position.clone(),
        world: world);

    test('Shrapnel sprays 3 lethal shards on an armed kill; shards do not '
        'respawn', () {
      pick('shrapnel');
      final killer =
          BulletState(position: Vector2(200, 200), velocity: Vector2(300, 0),
              bounces: 3);
      mods.kill(killCtx(killer, 1));
      expect(world.spawnedBullets, hasLength(3));
      for (final (state, _) in world.spawnedBullets) {
        expect(state.bounces, 3, reason: 'inherits lethality');
        expect(state.flags.suppressKillSpawn, isTrue);
      }

      // A shard's own kill sprays nothing (no cascade).
      world.spawnedBullets.clear();
      final shard = BulletState(
          position: Vector2.zero(),
          velocity: Vector2(1, 0),
          bounces: 3,
          flags: BulletFlags(suppressKillSpawn: true));
      mods.kill(killCtx(shard, 1));
      expect(world.spawnedBullets, isEmpty);
    });

    test('Shrapnel ignores an unarmed (0-bounce) kill', () {
      pick('shrapnel');
      final killer =
          BulletState(position: Vector2.zero(), velocity: Vector2(1, 0));
      mods.kill(killCtx(killer, 1));
      expect(world.spawnedBullets, isEmpty);
    });

    test('Chain Lightning forks a lethal bolt only on a chain kill with a '
        'target', () {
      pick('chain_lightning');
      world.nearestEnemy = Vector2(300, 200);

      // Single kill → no fork.
      mods.kill(killCtx(
          BulletState(
              position: Vector2(100, 200),
              velocity: Vector2(1, 0),
              bounces: 2),
          1));
      expect(world.spawnedBullets, isEmpty);

      // Chain kill → one bolt inheriting bounces, flagged.
      mods.kill(killCtx(
          BulletState(
              position: Vector2(100, 200),
              velocity: Vector2(1, 0),
              bounces: 2),
          2));
      expect(world.spawnedBullets, hasLength(1));
      expect(world.spawnedBullets.single.$1.bounces, 2);
      expect(world.spawnedBullets.single.$1.flags.suppressKillSpawn, isTrue);
    });
  });

  group('pity rule', () {
    test('guarantees a rare+ when forced and the pool has one', () {
      final rng = GameRng(3);
      for (var i = 0; i < 50; i++) {
        final draw =
            UpgradeDeck.draw3(rng, RunModifiers(), guaranteeRarePlus: true);
        expect(draw.any((c) => c.rarity != UpgradeRarity.common), isTrue);
      }
    });

    test('without the flag, all-common draws still happen', () {
      final rng = GameRng(1);
      var sawAllCommon = false;
      for (var i = 0; i < 800 && !sawAllCommon; i++) {
        final draw = UpgradeDeck.draw3(rng, RunModifiers());
        if (draw.every((c) => c.rarity == UpgradeRarity.common)) {
          sawAllCommon = true;
        }
      }
      expect(sawAllCommon, isTrue);
    });
  });

  group('UpgradeCatalog.tryById', () {
    test('returns the card for a known id', () {
      final card = UpgradeCatalog.tryById('split_shot');
      expect(card, isNotNull);
      expect(card!.id, 'split_shot');
    });

    test('returns null for an unknown/stale id instead of throwing', () {
      expect(UpgradeCatalog.tryById('removed_card_xyz'), isNull);
    });
  });
}
