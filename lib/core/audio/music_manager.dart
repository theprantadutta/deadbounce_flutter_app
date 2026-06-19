import 'package:flame_audio/flame_audio.dart';

import '../logging/app_logger.dart';

/// The looping background track to play.
enum MusicTrack { menu, combat, boss }

/// App-wide background music via `FlameAudio.bgm` (one looping track at a
/// time). Gracefully silent if the track file is absent (so the game runs
/// fine before the loops are added) or if music is toggled off.
class MusicManager {
  MusicManager._();
  static final MusicManager instance = MusicManager._();

  static const Map<MusicTrack, String> _files = {
    MusicTrack.menu: 'menu_loop.wav',
    MusicTrack.combat: 'combat_loop.wav',
    MusicTrack.boss: 'boss_loop.wav',
  };

  bool _enabled = true;
  MusicTrack? _current;

  /// True while playback is suspended because the app left the foreground —
  /// so we only resume music that we ourselves paused.
  bool _pausedForBackground = false;

  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    if (!value) {
      _stop();
    } else if (_current != null) {
      final resume = _current!;
      _current = null; // force a real (re)start
      play(resume);
    }
  }

  /// Plays (and loops) [track], replacing whatever is playing. No-op restart
  /// if the same track is already requested while enabled.
  Future<void> play(MusicTrack track) async {
    final same = _current == track;
    _current = track;
    if (!_enabled || same) return;
    try {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play(_files[track]!, volume: 0.45);
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[music] play ${track.name} failed');
    }
  }

  void stop() {
    _current = null;
    _stop();
  }

  /// The app left the foreground (home button, app switcher, screen off) —
  /// pause the loop so it isn't heard outside the game.
  void handleAppPaused() {
    if (_current == null || _pausedForBackground) return;
    _pausedForBackground = true;
    try {
      FlameAudio.bgm.pause();
    } catch (_) {}
  }

  /// The app returned to the foreground — resume the loop we paused (only if
  /// music is still enabled and a track was playing).
  void handleAppResumed() {
    if (!_pausedForBackground) return;
    _pausedForBackground = false;
    if (!_enabled || _current == null) return;
    try {
      FlameAudio.bgm.resume();
    } catch (_) {}
  }

  void _stop() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }
}
