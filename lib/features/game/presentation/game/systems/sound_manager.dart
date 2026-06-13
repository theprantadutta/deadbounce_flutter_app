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
/// Dropping in real SFX later means implementing this with flame_audio
/// in ONE file — no gameplay code changes.
abstract interface class SoundManager {
  void play(Sfx sfx, {double volume = 1.0});
  set enabled(bool value);
}

/// Phase-2 implementation: intentionally silent (real SFX are requested
/// from the project owner at the end of the phase). Logs in debug so the
/// hook points are visible during development.
class NoOpSoundManager implements SoundManager {
  bool _enabled = true;

  @override
  set enabled(bool value) => _enabled = value;

  @override
  void play(Sfx sfx, {double volume = 1.0}) {
    if (!_enabled) return;
    if (kDebugMode) {
      // Visible hook point; deliberately quiet in release.
      // debugPrint('SFX: ${sfx.name} @$volume');
    }
  }
}
