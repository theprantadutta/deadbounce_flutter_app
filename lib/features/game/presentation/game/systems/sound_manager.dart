import 'package:flutter/foundation.dart';

/// Every sound the game can make. The asset wishlist maps 1:1 to these.
enum Sfx {
  fire,
  bounce,
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
  gameOver,
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
