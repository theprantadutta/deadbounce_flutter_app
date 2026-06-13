import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import 'sound_manager.dart';

/// Real audio via flame_audio. The hot, frequently-played sounds (fire,
/// bounce, kill, coin) use AudioPools so rapid retriggers don't spawn a
/// new player each time; the rest play one-shot. All loading failures are
/// swallowed — missing audio must never crash a run.
class FlameAudioSoundManager implements SoundManager {
  FlameAudioSoundManager({bool enabled = true}) {
    _enabled = enabled;
  }

  late bool _enabled;
  bool _ready = false;
  final Map<Sfx, AudioPool> _pools = {};

  static const Map<Sfx, String> _files = {
    Sfx.fire: 'fire.wav',
    Sfx.bounce: 'bounce.wav',
    Sfx.kill: 'kill.wav',
    Sfx.chain: 'chain.wav',
    Sfx.hurt: 'hurt.wav',
    Sfx.dash: 'dash.wav',
    Sfx.upgrade: 'upgrade.wav',
    Sfx.wardenClang: 'warden_clang.wav',
    Sfx.wardenPhase: 'warden_phase.wav',
    Sfx.coin: 'coin.wav',
    Sfx.waveClear: 'wave_clear.wav',
    Sfx.uiTap: 'ui_tap.wav',
    Sfx.gameOver: 'game_over.wav',
  };

  /// Spammed sounds get pooled players to avoid latency/cutoff.
  static const Set<Sfx> _pooled = {
    Sfx.fire,
    Sfx.bounce,
    Sfx.kill,
    Sfx.coin,
  };

  @override
  set enabled(bool value) => _enabled = value;

  @override
  Future<void> preload() async {
    if (_ready) return;
    try {
      await FlameAudio.audioCache.loadAll(_files.values.toList());
      for (final sfx in _pooled) {
        _pools[sfx] = await FlameAudio.createPool(
          _files[sfx]!,
          minPlayers: 1,
          maxPlayers: 4,
        );
      }
      _ready = true;
    } catch (e) {
      if (kDebugMode) debugPrint('Audio preload failed: $e');
      // Leave _ready false → play() becomes a no-op rather than throwing.
    }
  }

  @override
  void play(Sfx sfx, {double volume = 1.0}) {
    if (!_enabled || !_ready) return;
    final v = volume.clamp(0.0, 1.0);
    final pool = _pools[sfx];
    if (pool != null) {
      // Fire-and-forget; the returned stop function is unused.
      pool.start(volume: v);
      return;
    }
    final file = _files[sfx];
    if (file != null) FlameAudio.play(file, volume: v);
  }

  @override
  void dispose() {
    for (final pool in _pools.values) {
      pool.dispose();
    }
    _pools.clear();
    _ready = false;
  }
}
