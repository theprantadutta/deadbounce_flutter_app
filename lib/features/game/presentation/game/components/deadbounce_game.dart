import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../engine/arena/arena_definition.dart';
import '../../../engine/challenge/challenge_config.dart';
import '../../../engine/combat/bullet_state.dart';
import '../../../engine/combat/bullet_stats.dart';
import '../../../engine/combat/score_system.dart';
import '../../../engine/game_rng.dart';
import '../../../engine/physics/ricochet_solver.dart';
import '../../../engine/physics/wall_segment.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import 'package:deadbounce_flutter_app/features/cosmetics/domain/cosmetic_loadout.dart';
import 'package:deadbounce_flutter_app/features/meta/domain/meta_loadout.dart';

import '../../../engine/trajectory/trajectory_predictor.dart';
import '../../../engine/trickshot/trickshot_level.dart';
import '../../../engine/upgrades/run_modifiers.dart';
import '../../../engine/upgrades/upgrade_card.dart';
import '../../../engine/upgrades/upgrade_catalog.dart';
import '../../../engine/upgrades/upgrade_deck.dart';
import '../../../engine/upgrades/upgrade_modifier.dart';
import '../game_feel.dart';
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
import 'trickshot_target_component.dart';

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
    this.challenge,
    this.metaLoadout = const MetaLoadout(),
    this.gameFeel = const GameFeel(),
    this.trickShotLevel,
    this.onTrickShotComplete,
    this.onTrickShotProgress,
    CosmeticLoadout? cosmetics,
  }) : haptics = hapticsService,
       cosmetics = cosmetics ?? CosmeticLoadout.stock,
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

  /// Run-shaping config when this is a daily challenge (null otherwise).
  final ChallengeConfig? challenge;

  /// Permanent Gunsmith bonuses for this run (empty for daily challenges).
  final MetaLoadout metaLoadout;

  /// Player-chosen feel/accessibility options (shake, hit-stop, aim guide,
  /// combat text, particle budget). Read by the systems below.
  final GameFeel gameFeel;

  /// Equipped cosmetics (visual only) — bullet trail, gunslinger skin, arena
  /// theme. Read live by the render code; never affects gameplay numbers.
  final CosmeticLoadout cosmetics;

  /// When non-null this is a Trick-Shot run: no waves/enemies, just the
  /// level's static targets to clear with bounced shots.
  final TrickShotLevel? trickShotLevel;

  /// Called once every trick-shot target is cleared.
  final void Function()? onTrickShotComplete;

  /// Called after each target is cleared with the count still remaining.
  final void Function(int remaining)? onTrickShotProgress;

  int _trickShotRemaining = 0;

  /// Extra i-frame seconds after a hit, from the Iron Resolve perk.
  double metaInvulnBonus = 0;

  final GameRng _runRng;
  late final GameRng _spawnRng = _runRng.fork('spawn');
  late final GameRng _wavesRng = _runRng.fork('waves');
  late final GameRng _upgradesRng = _runRng.fork('upgrades');
  late final GameRng _lootRng = _runRng.fork('loot');
  late final GameRng _modifiersRng = _runRng.fork('modifiers');
  late final GameRng enemyAiRng = _runRng.fork('enemyAi');

  late final List<WallSegment> segments = arenaDef.buildSegments();
  late final RicochetSolver solver = RicochetSolver(segments);
  late final RunModifiers modifiers = RunModifiers(
    bonusDamagePerBounce: challenge?.extraWallDamage ?? 0,
  );
  late final ScoreSystem scoreSystem = ScoreSystem(
    scoreMultiplier: challenge?.scoreMultiplier ?? 1,
  );
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
  int hitsTaken = 0;
  final Map<String, int> enemyKills = {};
  bool runEnded = false;

  /// Enemy id behind the most recent hit — read at run end for the death beat.
  String? lastDamageSource;

  @override
  Color backgroundColor() => AppColors.ink950;

  @override
  Future<void> onLoad() async {
    // World origin = arena top-left; camera looks at the center.
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2(arenaWidth / 2, arenaHeight / 2);

    // Permanent Gunsmith perks fold in before hearts/stats are read.
    _applyMetaLoadout();

    particles = ParticleFactory(
      world,
      _vfxRandom,
      budget: gameFeel.particleBudget,
    );
    juice = JuiceController(
      particles: particles,
      sound: sound,
      haptics: haptics,
      camera: camera,
      screenShake: gameFeel.screenShake,
      hitStopEnabled: gameFeel.hitStop,
    );
    // Shake oscillates around the look-at point.
    juice.setRestPosition(Vector2(arenaWidth / 2, arenaHeight / 2));

    spawner = SpawnDirector(game: this, arena: arenaDef, spawnRng: _spawnRng);

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

    // A challenge may cap the player's hearts (e.g. one-life gauntlet);
    // otherwise start full, including any permanent +heart perk.
    player.hearts = challenge?.startingHearts ?? effectiveMaxHearts();
    hud.maxHearts.value = effectiveMaxHearts();
    hud.hearts.value = player.hearts;

    // Trick-Shot: no waves — drop the level's static targets and wait for the
    // player to clear them all with bounced shots.
    if (trickShotLevel != null) {
      _spawnTrickShotTargets(trickShotLevel!);
      return;
    }

    waveRunner.startWave(1);
  }

  void _spawnTrickShotTargets(TrickShotLevel level) {
    _trickShotRemaining = level.targets.length;
    for (final t in level.targets) {
      world.add(
        TrickShotTargetComponent(
          position: t.position.clone(),
          requiredBounces: t.requiredBounces,
        ),
      );
    }
    // Defensive: a level authored with no targets is trivially complete (don't
    // soft-lock on a permanent "0 left").
    if (_trickShotRemaining == 0 && !runEnded) {
      runEnded = true;
      onTrickShotComplete?.call();
    }
  }

  /// A trick-shot target was cleared — juice it and finish when none remain.
  void onTrickShotTargetHit(TrickShotTargetComponent target) {
    juice.killFeedback(
      position: target.position.clone(),
      color: target.color,
      radius: target.bodyRadius,
      chainLength: 1,
    );
    _trickShotRemaining = math.max(0, _trickShotRemaining - 1);
    onTrickShotProgress?.call(_trickShotRemaining);
    if (_trickShotRemaining == 0 && !runEnded) {
      runEnded = true;
      juice.addTrauma(0.4);
      onTrickShotComplete?.call();
    }
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
    // Drain the chain meter live (frozen during hit-stop, since runTime is).
    final chain = scoreSystem.activeChain(runTime);
    hud.chainLength.value = chain?.length ?? 0;
    hud.chainRemaining.value = chain?.remaining ?? 0;
  }

  // ---- queries used by components ----

  Iterable<EnemyComponent> get aliveEnemies =>
      world.children.query<EnemyComponent>().where((e) => !e.isDead);

  Iterable<BulletComponent> get aliveBullets =>
      world.children.query<BulletComponent>();

  void refreshTrajectory(Vector2 direction, double powerT) {
    final stats = modifiers.effectiveBulletStats();
    final playerStats = modifiers.effectivePlayerStats();
    final speed =
        GameBalance.I.bullet.minSpeed +
        (GameBalance.I.bullet.maxSpeed - GameBalance.I.bullet.minSpeed) *
            powerT;
    // Every 4th shot is the ghost shot when Ghost Round is held — show it.
    final ghostHeld = modifiers.stacksOf('ghost_round') > 0;
    final nextIsGhost = ghostHeld && (player.shotCounter + 1) % 4 == 0;

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
    if (label != null && gameFeel.combatText) {
      world.add(
        PopupTextComponent.chainLabel(
          label,
          enemy.position + Vector2(0, -enemy.bodyRadius - 30),
        ),
      );
    }

    // Kill coins + chance of a dropped pickup.
    addRunCoins(
      GameBalance.I.economy.coinPerKill.toDouble() +
          (chainLength > 1 ? GameBalance.I.economy.chainBonusPerKill : 0),
    );
    if (_lootRng.chance(GameBalance.I.economy.dropChance)) {
      world.add(
        CoinPickupComponent(
          position: enemy.position.clone(),
          value: GameBalance.I.economy.dropValue,
        ),
      );
    }

    // Upgrade hooks.
    if (killer != null) {
      modifiers.kill(
        KillContext(
          bullet: killer.state,
          enemyType: enemy.enemyId,
          chainLength: chainLength,
          position: enemy.position.clone(),
          world: this,
        ),
      );
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

  /// Base + Heart-Container max hearts. The base is the challenge cap when
  /// present, else the tuning default — so a one-life challenge plus a
  /// Heart Container still tops out at two, not four.
  int effectiveMaxHearts() =>
      (challenge?.startingHearts ?? GameBalance.I.player.maxHearts) +
      modifiers.stacksOf('heart_container');

  /// Folds the permanent Gunsmith perks into this run: card-shaped perks
  /// become pre-loaded modifier stacks, Iron Resolve adds i-frame seconds,
  /// and Second Wind grants one free random common upgrade.
  void _applyMetaLoadout() {
    metaLoadout.permanentCards.forEach((cardId, stacks) {
      final card = UpgradeCatalog.tryById(cardId);
      if (card == null) return; // stale/removed card id — skip, don't crash
      for (var i = 0; i < stacks; i++) {
        // Never exceed the card's own stack cap, even if a future perk's
        // maxLevel is raised above it.
        if (modifiers.stacksOf(card.id) >= card.maxStacks) break;
        modifiers.addPermanent(card);
      }
    });
    metaInvulnBonus = metaLoadout.invulnBonus;
    if (metaLoadout.grantFreeCard) {
      final commons = UpgradeCatalog.all
          .where(
            (c) =>
                c.rarity == UpgradeRarity.common &&
                modifiers.stacksOf(c.id) < c.maxStacks,
          )
          .toList();
      if (commons.isNotEmpty) {
        modifiers.addPermanent(_runRng.fork('meta').pick(commons));
      }
    }
  }

  void onWaveCleared(int wave) {
    if (runEnded) return;
    scoreSystem.registerWaveClear(wave);
    hud.score.value = scoreSystem.score;
    addRunCoins(GameBalance.I.economy.waveClearBonus.toDouble());
    sound.play(Sfx.waveClear);

    final choices = UpgradeDeck.draw3(_upgradesRng, modifiers);

    // "Wild Draw" challenge: upgrades are dealt at random, no picker.
    if (challenge?.randomUpgrades ?? false) {
      _addUpgrade(choices[_upgradesRng.nextInt(choices.length)]);
      waveRunner.startWave(wave + 1);
      return;
    }

    pauseEngine();
    gateway.onWaveCleared(wave, choices);
  }

  /// Called by the cubit after the player picks a card.
  void applyUpgrade(UpgradeCard card) {
    _addUpgrade(card);
    resumeEngine();
    waveRunner.startWave(waveRunner.currentWave + 1);
  }

  void _addUpgrade(UpgradeCard card) {
    modifiers.add(card);
    if (card.id == 'heart_container') {
      player.heal(1);
    }
    hud.maxHearts.value = effectiveMaxHearts();
    publishActiveUpgrades();
    sound.play(Sfx.upgrade);
  }

  /// Pushes the drafted build (deduped, with stack counts) to the HUD tray.
  /// Also covers meta perks pre-loaded at run start.
  void publishActiveUpgrades() {
    final seen = <String>{};
    final list = <HudUpgrade>[];
    for (final id in modifiers.pickedIds) {
      if (!seen.add(id)) continue;
      final card = UpgradeCatalog.tryById(id);
      if (card == null) continue;
      list.add(
        HudUpgrade(
          id: id,
          name: card.name,
          iconName: card.iconName,
          stacks: modifiers.stacksOf(id),
        ),
      );
    }
    hud.activeUpgrades.value = list;
  }

  void endRun() {
    if (runEnded) return;
    runEnded = true;
    sound.play(Sfx.gameOver);
    // A punchy freeze-frame so the kill lands before the death beat fades in.
    juice.hitStop(0.45);
    juice.addTrauma(0.6);

    gateway.onRunEnded(
      RunStatsSnapshot(
        score: scoreSystem.score,
        waveReached: waveRunner.currentWave,
        kills: kills,
        bestChain: scoreSystem.bestChain,
        maxBounceKill: scoreSystem.maxBounceKill,
        coinsEarned: coinsEarned,
        durationSeconds: runTime,
        upgradesPicked: List.of(modifiers.pickedIds),
        enemyKills: Map.of(enemyKills),
        hitsTaken: hitsTaken,
        causeOfDeath: lastDamageSource,
      ),
    );
  }

  // ---- GameWorldOps (upgrade modifier seam) ----

  @override
  void spawnBullet(
    BulletState state,
    BulletStats stats, {
    double delaySeconds = 0,
  }) {
    if (delaySeconds <= 0) {
      world.add(BulletComponent(state: state, stats: stats));
    } else {
      world.add(
        _DelayedSpawn(
          delay: delaySeconds,
          spawn: () => world.add(BulletComponent(state: state, stats: stats)),
        ),
      );
    }
  }

  @override
  void spawnFireTrail(
    Vector2 position,
    double radius,
    double duration,
    int damagePerSecond,
  ) {
    world.add(
      FireTrailComponent(
        position: position,
        radius: radius,
        duration: duration,
        damagePerSecond: damagePerSecond,
      ),
    );
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
