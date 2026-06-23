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
        switch (card.rarity.weight) {
          case 100:
            commons++;
          case 12:
            epics++;
        }
      }
    }
    expect(commons, greaterThan(epics * 3));
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
