import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../engine/physics/vector_utils.dart';
import '../../../engine/tuning.dart';

/// All procedural particle recipes, budgeted. Glow is faked with layered
/// translucent circles — MaskFilter.blur is reserved for static walls and
/// rare big moments (it's the real perf cliff, not particle count).
class ParticleFactory {
  ParticleFactory(this._world, this._vfxRandom);

  /// VFX randomness is unseeded on purpose: juice must never consume
  /// gameplay entropy.
  final math.Random _vfxRandom;
  final World _world;

  int _alive = 0;

  bool get _overBudget => _alive >= Tuning.juice.particleBudget;

  void _spawn(Particle particle, Vector2 position, {int weight = 1}) {
    if (_overBudget) return;
    _alive += weight;
    _world.add(
      ParticleSystemComponent(
        particle: particle,
        position: position,
        priority: 50,
      )..removed.then((_) => _alive -= weight),
    );
  }

  double _rand(double min, double max) =>
      min + _vfxRandom.nextDouble() * (max - min);

  /// Muzzle flash on fire: a short radial burst along the fire direction.
  void muzzleFlash(Vector2 position, Vector2 direction) {
    final count = _overBudget ? 0 : 8;
    if (count == 0) return;
    _spawn(
      Particle.generate(
        count: count,
        lifespan: 0.18,
        generator: (i) {
          final spread = _rand(-0.5, 0.5);
          final dir = direction.clone()
            ..rotateBy(spread)
            ..scale(_rand(180, 360));
          return AcceleratedParticle(
            speed: dir,
            child: _spark(AppColors.amber300, _rand(2, 4)),
          );
        },
      ),
      position,
      weight: count,
    );
  }

  /// Wall-bounce sparks — count and heat scale with the bounce count.
  void bounceSparks(Vector2 position, Vector2 normal, int bounces,
      {bool dampened = false}) {
    final count = dampened ? 3 : math.min(6 + bounces * 3, 18);
    if (_overBudget) return;
    final color = dampened
        ? AppColors.ink300
        : Color.lerp(AppColors.amber500, const Color(0xFFFFFFFF),
            (bounces / Tuning.bullet.maxBounces).clamp(0.0, 1.0))!;
    _spawn(
      Particle.generate(
        count: count,
        lifespan: 0.35,
        generator: (i) {
          final dir = normal.clone()
            ..rotateBy(_rand(-1.1, 1.1))
            ..scale(_rand(120, 260 + bounces * 30));
          return AcceleratedParticle(
            speed: dir,
            acceleration: dir * -1.4,
            child: _spark(color, _rand(1.5, 3.5)),
          );
        },
      ),
      position,
      weight: count,
    );
  }

  /// Enemy death: geometric shards in the enemy's color.
  void deathShatter(Vector2 position, Color color, double radius) {
    final count = _overBudget ? 0 : 10;
    if (count == 0) return;
    _spawn(
      Particle.generate(
        count: count,
        lifespan: 0.55,
        generator: (i) {
          final dir = Vector2(_rand(-1, 1), _rand(-1, 1))
            ..normalize()
            ..scale(_rand(140, 320));
          final spin = _rand(-8, 8);
          final size = _rand(radius * 0.18, radius * 0.4);
          return AcceleratedParticle(
            speed: dir,
            acceleration: dir * -1.2,
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final t = particle.progress;
                final paint = Paint()
                  ..color = color.withValues(alpha: (1 - t).clamp(0, 1));
                canvas.save();
                canvas.rotate(spin * t);
                final s = size * (1 - t * 0.5);
                final path = Path()
                  ..moveTo(0, -s)
                  ..lineTo(s * 0.9, s * 0.7)
                  ..lineTo(-s * 0.9, s * 0.7)
                  ..close();
                canvas.drawPath(path, paint);
                canvas.restore();
              },
            ),
          );
        },
      ),
      position,
      weight: count,
    );
  }

  /// Coin pickup sparkle.
  void coinSparkle(Vector2 position) {
    if (_overBudget) return;
    _spawn(
      Particle.generate(
        count: 6,
        lifespan: 0.4,
        generator: (i) {
          final angle = (i / 6) * math.pi * 2;
          final dir = Vector2(math.cos(angle), math.sin(angle))..scale(90);
          return AcceleratedParticle(
            speed: dir,
            child: _spark(AppColors.amber200, 2.2),
          );
        },
      ),
      position,
      weight: 6,
    );
  }

  /// Pass-through ping at bounce 0 — teaches "no damage till it bounces".
  void passThroughPing(Vector2 position) {
    if (_overBudget) return;
    _spawn(
      ComputedParticle(
        lifespan: 0.25,
        renderer: (canvas, particle) {
          final t = particle.progress;
          canvas.drawCircle(
            Offset.zero,
            6 + t * 18,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = AppColors.blue300
                  .withValues(alpha: (0.5 * (1 - t)).clamp(0, 1)),
          );
        },
      ),
      position,
      weight: 2,
    );
  }

  Particle _spark(Color color, double size) => ComputedParticle(
        renderer: (canvas, particle) {
          final alpha = (1 - particle.progress).clamp(0.0, 1.0);
          // Fake glow: soft halo + hot core, no blur filter.
          canvas.drawCircle(Offset.zero, size * 2.2,
              Paint()..color = color.withValues(alpha: alpha * 0.25));
          canvas.drawCircle(Offset.zero, size,
              Paint()..color = color.withValues(alpha: alpha));
        },
      );
}

/// Long-lived ambient ember drift — desert haze in brand colors.
class AmbientDustComponent extends Component {
  AmbientDustComponent({required this.bounds, required this._random});

  final Vector2 bounds;
  final math.Random _random;
  static const int _count = 36;

  final List<_Ember> _embers = [];

  @override
  Future<void> onLoad() async {
    priority = 5;
    for (var i = 0; i < _count; i++) {
      _embers.add(_newEmber(anywhere: true));
    }
  }

  _Ember _newEmber({bool anywhere = false}) => _Ember(
        position: Vector2(
          _random.nextDouble() * bounds.x,
          anywhere ? _random.nextDouble() * bounds.y : bounds.y + 10,
        ),
        velocity: Vector2(
          (_random.nextDouble() - 0.5) * 14,
          -(8 + _random.nextDouble() * 22),
        ),
        size: 1.2 + _random.nextDouble() * 2.2,
        amber: _random.nextDouble() < 0.7,
        phase: _random.nextDouble() * math.pi * 2,
      );

  @override
  void update(double dt) {
    for (var i = 0; i < _embers.length; i++) {
      final e = _embers[i];
      e.position.addScaled(e.velocity, dt);
      e.phase += dt;
      if (e.position.y < -10) _embers[i] = _newEmber();
    }
  }

  @override
  void render(Canvas canvas) {
    for (final e in _embers) {
      final flicker = 0.25 + 0.2 * math.sin(e.phase * 3);
      final color = (e.amber ? AppColors.amber400 : AppColors.blue400)
          .withValues(alpha: flicker.clamp(0.05, 0.5));
      canvas.drawCircle(e.position.toOffset(), e.size, Paint()..color = color);
    }
  }
}

class _Ember {
  _Ember({
    required this.position,
    required this.velocity,
    required this.size,
    required this.amber,
    required this.phase,
  });

  final Vector2 position;
  final Vector2 velocity;
  final double size;
  final bool amber;
  double phase;
}
