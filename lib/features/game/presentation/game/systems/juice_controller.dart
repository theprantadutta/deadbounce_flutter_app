import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'package:deadbounce_flutter_app/core/config/game_balance.dart';

import 'haptics_service.dart';
import 'particle_factory.dart';
import 'sound_manager.dart';

/// Game feel, centralized: hit-stop, trauma-model screen shake, and the
/// composed feedback moments (kills, chains, Warden hits). Particles and
/// audio are owned here so gameplay components ask for FEEDBACK, not for
/// effects.
class JuiceController {
  JuiceController({
    required this.particles,
    required this.sound,
    required this.haptics,
    required this._camera,
  });

  final ParticleFactory particles;
  final SoundManager sound;
  final HapticsService haptics;
  final CameraComponent _camera;

  double _hitStopRemaining = 0;
  double _trauma = 0;
  double _shakeTime = 0;
  final Vector2 _restPosition = Vector2.zero();

  /// The camera's true look-at point — shake oscillates around it and
  /// restores it exactly.
  void setRestPosition(Vector2 position) => _restPosition.setFrom(position);

  /// Called by DeadbounceGame.update with RAW dt. Returns the dt the
  /// world should advance by (0 while frozen). Timers/Future.delayed
  /// would drift against engine pause — raw-dt accounting can't.
  double consumeHitStop(double rawDt) {
    if (_hitStopRemaining > 0) {
      _hitStopRemaining -= rawDt;
      return 0;
    }
    return rawDt;
  }

  /// Shake decays on raw dt too — it must finish even during hit-stop.
  void updateShake(double rawDt) {
    if (_trauma <= 0) return;
    _trauma =
        (_trauma - GameBalance.I.juice.shakeDecayPerSecond * rawDt).clamp(0.0, 1.0);
    _shakeTime += rawDt * 40;

    if (_trauma <= 0) {
      // Exact restore — the camera is anchored at world center.
      _camera.viewfinder.position = _restPosition.clone();
      return;
    }

    final magnitude = GameBalance.I.juice.shakeMaxOffset * _trauma * _trauma;
    _camera.viewfinder.position = _restPosition +
        Vector2(
          magnitude * (math.sin(_shakeTime * 1.1) + math.sin(_shakeTime * 2.3)) / 2,
          magnitude * (math.cos(_shakeTime * 0.9) + math.cos(_shakeTime * 2.7)) / 2,
        );
  }

  void hitStop(double seconds) {
    _hitStopRemaining = math.max(_hitStopRemaining, seconds);
  }

  void addTrauma(double amount) {
    _trauma = (_trauma + amount).clamp(0.0, 1.0);
  }

  /// Composed kill feedback: shatter + sound + haptic, escalating with
  /// chain length (hit-stop and big shake on multi-kills).
  void killFeedback({
    required Vector2 position,
    required Color color,
    required double radius,
    required int chainLength,
  }) {
    particles.deathShatter(position, color, radius);
    addTrauma(chainLength >= 2
        ? GameBalance.I.juice.shakeTraumaChain
        : GameBalance.I.juice.shakeTraumaKill);
    if (chainLength >= 2) {
      hitStop(GameBalance.I.juice.hitStopMultiKill);
      sound.play(Sfx.chain);
      haptics.heavy();
    } else {
      sound.play(Sfx.kill);
      haptics.medium();
    }
  }

  void wardenFeedback(Vector2 position) {
    hitStop(GameBalance.I.juice.hitStopWardenHit);
    addTrauma(GameBalance.I.juice.shakeTraumaBoss);
    sound.play(Sfx.wardenPhase);
    haptics.heavy();
  }
}
