import 'package:flame/components.dart';

import 'package:deadbounce_flutter_app/core/audio/music_manager.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';

import '../../../engine/game_rng.dart';
import '../../../engine/waves/wave_definition.dart';
import '../../../engine/waves/wave_scaling.dart';
import '../components/deadbounce_game.dart';
import 'spawn_director.dart';

/// Executes wave definitions: schedules spawn groups through the
/// SpawnDirector, watches the alive count, and reports wave-clear to the
/// game after a short beat.
class WaveRunner extends Component with HasGameReference<DeadbounceGame> {
  WaveRunner({required this._spawner, required GameRng wavesRng})
      : _rng = wavesRng;

  final SpawnDirector _spawner;
  final GameRng _rng;

  int currentWave = 0;
  WaveDefinition? _definition;
  final List<_PendingGroupSpawn> _schedule = [];
  double _waveTime = 0;
  bool _spawningDone = false;
  bool _waveActive = false;
  double _clearBeat = 0;

  void startWave(int wave) {
    currentWave = wave;
    _definition = WaveScaling.forWave(wave, _rng);
    _waveTime = 0;
    _spawningDone = false;
    _waveActive = true;
    _clearBeat = 0;
    game.hud.wave.value = wave;

    // Swap to the boss loop on a Warden wave; otherwise (re)assert the combat
    // loop, so it returns to normal on the wave after the Warden falls.
    MusicManager.instance
        .play(_definition!.hasBoss ? MusicTrack.boss : MusicTrack.combat);

    // A daily challenge may force a single enemy type. Wardens always pass
    // through so boss waves still happen.
    final forced = game.challenge?.forcedEnemyType;

    _schedule.clear();
    for (final group in _definition!.groups) {
      final type = (forced != null && group.type != EnemyType.warden)
          ? forced
          : group.type;
      for (var i = 0; i < group.count; i++) {
        _schedule.add(_PendingGroupSpawn(
          at: group.delay + i * group.stagger,
          type: type,
        ));
      }
    }
    _schedule.sort((a, b) => a.at.compareTo(b.at));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_waveActive || game.runEnded) return;

    _waveTime += dt;

    while (_schedule.isNotEmpty && _schedule.first.at <= _waveTime) {
      final next = _schedule.removeAt(0);
      _spawner.spawnTelegraphed(
        next.type,
        hpMult: _definition!.hpMult,
        speedMult: _definition!.speedMult,
      );
    }
    if (_schedule.isEmpty) _spawningDone = true;

    if (_spawningDone && _spawner.activeCount == 0) {
      // Short beat before the upgrade picker so the last kill lands.
      _clearBeat += dt;
      if (_clearBeat >= GameBalance.I.waves.interWaveDelay) {
        _waveActive = false;
        game.onWaveCleared(currentWave);
      }
    } else {
      _clearBeat = 0;
    }
  }
}

class _PendingGroupSpawn {
  _PendingGroupSpawn({required this.at, required this.type});
  final double at;
  final EnemyType type;
}
