import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../engine/arena/arena_definition.dart';
import '../../../engine/combat/bullet_state.dart';
import '../../../engine/combat/bullet_stats.dart';
import '../../../engine/combat/score_system.dart';
import '../../../engine/game_rng.dart';
import '../../../engine/physics/ricochet_solver.dart';
import '../../../engine/physics/wall_segment.dart';
import '../../../engine/trajectory/trajectory_predictor.dart';
import '../../../engine/tuning.dart';
import '../../../engine/upgrades/run_modifiers.dart';
import '../../../engine/upgrades/upgrade_card.dart';
import '../../../engine/upgrades/upgrade_catalog.dart';
import '../../../engine/upgrades/upgrade_deck.dart';
import '../../../engine/upgrades/upgrade_modifier.dart';
import '../game_session_gateway.dart';
import '../hud_model.dart';
import '../systems/haptics_service.dart';
import '../systems/input_controller.dart';
import '../systems/juice_controller.dart';
import '../systems/particle_factory.dart';
import '../systems/sound_manager.dart';
import '../systems/spawn_director.dart';
import '../systems/wave_runner.dart';
import 'arena_component.dart';
import 'bullet_component.dart';
import 'coin_pickup_component.dart';
import 'enemies/enemy_component.dart';
import 'fire_trail_component.dart';
import 'player_component.dart';
import 'popup_text_component.dart';
import 'trajectory_component.dart';

/// The Deadbounce arena game. Implements [GameWorldOps] so upgrade
/// modifiers act on the world through a seam that tests can fake.
class DeadbounceGame extends FlameGame implements GameWorldOps {
  DeadbounceGame({
    required this.gateway,
    required this.hud,
    required this.arenaDef,
    required this._runRng,
    required HapticsService hapticsService,
    required this.sound,
    this.isDailyChallenge = false,
    this.challengeDate,
  })  : haptics = hapticsService,
        super(
          camera: CameraComponent.withFixedResolution(
            width: arenaWidth,
            height: arenaHeight,
          ),
        );

  static const double arenaWidth = ArenaDefinition.width;
  static const double arenaHeight = ArenaDefinition.height;

  final GameSessionGateway gateway;
  final HudModel hud;
  final ArenaDefinition arenaDef;
  final SoundManager sound;
  final HapticsService haptics;
  final bool isDailyChallenge;
  final String? challengeDate;

  final GameRng _runRng;
  late final GameRng _spawnRng = _runRng.fork('spawn');
  late final GameRng _wavesRng = _runRng.fork('waves');
  late final GameRng _upgradesRng = _runRng.fork('upgrades');
  late final GameRng _lootRng = _runRng.fork('loot');
  late final GameRng _modifiersRng = _runRng.fork('modifiers');
  late final GameRng enemyAiRng = _runRng.fork('enemyAi');

  late final List<WallSegment> segments = arenaDef.buildSegments();
  late final RicochetSolver solver = RicochetSolver(segments);
  final RunModifiers modifiers = RunModifiers();
  final ScoreSystem scoreSystem = ScoreSystem();
  late final SpawnDirector spawner;
  late final WaveRunner waveRunner;
  late final PlayerComponent player;
  late final TrajectoryComponent trajectory;
  late final ParticleFactory particles;
  late final JuiceController juice;

  final math.Random _vfxRandom = math.Random();

  double runTime = 0;
  int kills = 0;
  int coinsEarned = 0;
  final Map<String, int> enemyKills = {};
  bool runEnded = false;

  @override
  Color backgroundColor() => AppColors.ink950;

  @override
  Future<void> onLoad() async {
    // World origin = arena top-left; camera looks at the center.
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2(arenaWidth / 2, arenaHeight / 2);

    particles = ParticleFactory(world, _vfxRandom);
    juice = JuiceController(
      particles: particles,
      sound: sound,
      haptics: haptics,
      camera: camera,
    );
    // Shake oscillates around the look-at point.
    juice.setRestPosition(Vector2(arenaWidth / 2, arenaHeight / 2));

    spawner = SpawnDirector(
      game: this,
      arena: arenaDef,
      spawnRng: _spawnRng,
    );

    player = PlayerComponent(anchors: arenaDef.anchors());
    trajectory = TrajectoryComponent()..priority = 15;
    waveRunner = WaveRunner(spawner: spawner, wavesRng: _wavesRng);

    await world.addAll([
      ArenaComponent(segments: segments),
      AmbientDustComponent(
        bounds: Vector2(arenaWidth, arenaHeight),
        random: _vfxRandom,
      ),
      trajectory,
      player,
      waveRunner,
      InputController(),
    ]);

    hud.maxHearts.value = Tuning.player.maxHearts;
    hud.hearts.value = player.hearts;

    waveRunner.startWave(1);
  }

  @override
  void update(double dt) {
    final clamped = math.min(dt, 1 / 20); // spiral-of-death guard
    juice.updateShake(clamped);
    final effective = juice.consumeHitStop(clamped);
    if (effective > 0) {
      if (!runEnded) runTime += effective;
      super.update(effective);
    }
  }

  // ---- queries used by components ----

  Iterable<EnemyComponent> get aliveEnemies =>
      world.children.query<EnemyComponent>().where((e) => !e.isDead);

  Iterable<BulletComponent> get aliveBullets =>
      world.children.query<BulletComponent>();

  void refreshTrajectory(Vector2 direction, double powerT) {
    final stats = modifiers.effectiveBulletStats();
    final playerStats = modifiers.effectivePlayerStats();
    final speed = Tuning.bullet.minSpeed +
        (Tuning.bullet.maxSpeed - Tuning.bullet.minSpeed) * powerT;
    // Every 4th shot is the ghost shot when Ghost Round is held — show it.
    final ghostHeld = modifiers.stacksOf('ghost_round') > 0;
    final nextIsGhost =
        ghostHeld && (player.shotCounter + 1) % 4 == 0;

    trajectory.nodes = TrajectoryPredictor.predict(
      solver,
      player.muzzlePosition,
      direction,
      stats: stats,
      previewBounces: playerStats.previewBounces,
      launchSpeed: speed,
      ghostPasses: nextIsGhost ? 1 : 0,
    );
  }

  // ---- run events ----

  void onEnemyKilled(EnemyComponent enemy, BulletComponent? killer) {
    kills++;
    enemyKills[enemy.enemyId] = (enemyKills[enemy.enemyId] ?? 0) + 1;

    final bounces = killer?.state.bounces ?? 0;
    final chainLength = scoreSystem.registerKill(
      bulletId: killer?.hashCode ?? -1,
      bounces: bounces,
      now: runTime,
    );
    hud.score.value = scoreSystem.score;

    juice.killFeedback(
      position: enemy.position.clone(),
      color: enemy.color,
      radius: enemy.bodyRadius,
      chainLength: chainLength,
    );

    final label = ScoreSystem.chainLabel(chainLength);
    if (label != null) {
      world.add(PopupTextComponent.chainLabel(
        label,
        enemy.position + Vector2(0, -enemy.bodyRadius - 30),
      ));
    }

    // Kill coins + chance of a dropped pickup.
    addRunCoins(Tuning.economy.coinPerKill.toDouble() +
        (chainLength > 1 ? Tuning.economy.chainBonusPerKill : 0));
    if (_lootRng.chance(Tuning.economy.dropChance)) {
      world.add(CoinPickupComponent(
        position: enemy.position.clone(),
        value: Tuning.economy.dropValue,
      ));
    }

    // Upgrade hooks.
    if (killer != null) {
      modifiers.kill(KillContext(
        bullet: killer.state,
        enemyType: enemy.enemyId,
        chainLength: chainLength,
        position: enemy.position.clone(),
        world: this,
      ));
    }
  }

  void collectCoin(int value, Vector2 position) {
    particles.coinSparkle(position);
    sound.play(Sfx.coin);
    addRunCoins(value.toDouble());
  }

  /// All coin grants flow through the modifier pipeline (Coin Magnet).
  void addRunCoins(double amount) {
    final ctx = CoinContext(amount);
    modifiers.coinEarned(ctx);
    coinsEarned += ctx.amount.round();
    hud.coins.value = coinsEarned;
  }

  void onWaveCleared(int wave) {
    if (runEnded) return;
    scoreSystem.registerWaveClear(wave);
    hud.score.value = scoreSystem.score;
    addRunCoins(Tuning.economy.waveClearBonus.toDouble());
    sound.play(Sfx.waveClear);

    pauseEngine();
    gateway.onWaveCleared(wave, UpgradeDeck.draw3(_upgradesRng, modifiers));
  }

  /// Called by the cubit after the player picks a card.
  void applyUpgrade(UpgradeCard card) {
    modifiers.add(card);
    if (card.id == 'heart_container') {
      player.heal(1);
    }
    hud.maxHearts.value = modifiers.effectivePlayerStats().maxHearts;
    sound.play(Sfx.upgrade);
    resumeEngine();
    waveRunner.startWave(waveRunner.currentWave + 1);
  }

  void endRun() {
    if (runEnded) return;
    runEnded = true;
    sound.play(Sfx.gameOver);

    gateway.onRunEnded(RunStatsSnapshot(
      score: scoreSystem.score,
      waveReached: waveRunner.currentWave,
      kills: kills,
      bestChain: scoreSystem.bestChain,
      maxBounceKill: scoreSystem.maxBounceKill,
      coinsEarned: coinsEarned,
      durationSeconds: runTime,
      upgradesPicked: List.of(modifiers.pickedIds),
      enemyKills: Map.of(enemyKills),
    ));
  }

  // ---- GameWorldOps (upgrade modifier seam) ----

  @override
  void spawnBullet(BulletState state, BulletStats stats,
      {double delaySeconds = 0}) {
    if (delaySeconds <= 0) {
      world.add(BulletComponent(state: state, stats: stats));
    } else {
      world.add(_DelayedSpawn(
        delay: delaySeconds,
        spawn: () => world.add(BulletComponent(state: state, stats: stats)),
      ));
    }
  }

  @override
  void spawnFireTrail(Vector2 position, double radius, double duration,
      int damagePerSecond) {
    world.add(FireTrailComponent(
      position: position,
      radius: radius,
      duration: duration,
      damagePerSecond: damagePerSecond,
    ));
  }

  @override
  Vector2? nearestEnemyTo(Vector2 position, {required double within}) {
    Vector2? best;
    var bestDist = within;
    for (final enemy in aliveEnemies) {
      final d = enemy.position.distanceTo(position);
      if (d < bestDist) {
        bestDist = d;
        best = enemy.position;
      }
    }
    return best?.clone();
  }

  @override
  GameRng get rng => _modifiersRng;

  /// Catalog passthrough so the cubit can resolve card ids without
  /// importing engine internals.
  UpgradeCard upgradeById(String id) => UpgradeCatalog.byId(id);
}

class _DelayedSpawn extends Component {
  _DelayedSpawn({required this.delay, required this.spawn});

  final double delay;
  final void Function() spawn;
  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= delay) {
      spawn();
      removeFromParent();
    }
  }
}
