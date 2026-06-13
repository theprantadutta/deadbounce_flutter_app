import 'package:flutter/foundation.dart';

/// Every sound the game can make. Each maps 1:1 to an `assets/audio/` file.
enum Sfx {
  fire,

  /// Generic / dampened wall bounce. Real (counted) bounces use the
  /// pitched [bounce1]/[bounce2]/[bounce3] variants instead.
  bounce,
  bounce1,
  bounce2,
  bounce3,
  kill,
  chain,
  hurt,
  dash,
  upgrade,
  wardenClang,
  wardenPhase,
  coin,
  waveClear,
  uiTap,
  gameOver;

  /// The pitched bounce that climbs with the bullet's bounce count:
  /// 1 → low, 2 → mid, 3+ → high (deadlier = hotter).
  static Sfx bounceFor(int bounceCount) => switch (bounceCount) {
        <= 1 => bounce1,
        2 => bounce2,
        _ => bounce3,
      };
}

/// Audio seam: gameplay calls [play]; the implementation is swappable.
/// [preload] warms the clips before a run; [dispose] releases players.
abstract interface class SoundManager {
  /// Loads the clips. Safe to call once per run; cached after first load.
  Future<void> preload();
  void play(Sfx sfx, {double volume = 1.0});
  set enabled(bool value);
  void dispose();
}

/// Silent fallback — used in tests and as a safe default if audio fails
/// to load.
class NoOpSoundManager implements SoundManager {
  bool _enabled = true;

  @override
  set enabled(bool value) => _enabled = value;

  @override
  Future<void> preload() async {}

  @override
  void play(Sfx sfx, {double volume = 1.0}) {
    if (!_enabled) return;
    if (kDebugMode) {
      // Visible hook point; deliberately quiet in release.
      // debugPrint('SFX: ${sfx.name} @$volume');
    }
  }

  @override
  void dispose() {}
}
