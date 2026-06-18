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
    MusicTrack.menu: 'menu_loop.mp3',
    MusicTrack.combat: 'combat_loop.mp3',
    MusicTrack.boss: 'boss_loop.mp3',
  };

  bool _enabled = true;
  MusicTrack? _current;

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

  void _stop() {
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
  }
}
