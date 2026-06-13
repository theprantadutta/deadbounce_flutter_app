import '../tuning.dart';

/// One registered kill, for chain bookkeeping.
class _ChainEntry {
  _ChainEntry(this.bulletId, this.time, this.length);
  final int bulletId;
  final double time;
  int length;
}

/// Scoring: kill base × bounce multiplier, chain detection per bullet
/// (kills by the same bullet within the chain window), wave-clear bonuses.
/// [scoreMultiplier] applies a flat run-wide factor (daily challenges).
/// Pure Dart — fully unit-tested.
class ScoreSystem {
  ScoreSystem({this.scoreMultiplier = 1});

  /// Run-wide score factor (1 normally; challenges may double/triple it).
  final double scoreMultiplier;

  int _score = 0;
  int _bestChain = 0;
  int _maxBounceKill = 0;
  final Map<int, _ChainEntry> _chains = {};

  int get score => _score;
  int get bestChain => _bestChain;
  int get maxBounceKill => _maxBounceKill;

  /// Registers a kill at [now] (game-time seconds) by bullet [bulletId]
  /// with [bounces] on the killing bullet. Returns the chain length this
  /// kill belongs to (1 = no chain yet).
  int registerKill({
    required int bulletId,
    required int bounces,
    required double now,
  }) {
    const t = Tuning.score;

    final killScore =
        (t.killBase * (1 + t.bounceFactor * bounces)).round();
    _addScore(killScore);

    if (bounces > _maxBounceKill) _maxBounceKill = bounces;

    final entry = _chains[bulletId];
    int chainLength;
    if (entry != null && now - entry.time <= t.chainWindow) {
      entry.length += 1;
      chainLength = entry.length;
      _addScore(t.chainBonus);
      _chains[bulletId] = _ChainEntry(bulletId, now, chainLength);
    } else {
      chainLength = 1;
      _chains[bulletId] = _ChainEntry(bulletId, now, 1);
    }

    if (chainLength > _bestChain) _bestChain = chainLength;
    return chainLength;
  }

  void registerWaveClear(int wave) {
    _addScore(Tuning.score.waveClearBase * wave);
  }

  void _addScore(int raw) {
    _score += (raw * scoreMultiplier).round();
  }

  /// Punchy chain copy, in the Deadbounce voice.
  static String? chainLabel(int chainLength) => switch (chainLength) {
        <= 1 => null,
        2 => 'DOUBLE KILL',
        3 => 'TRIPLE KILL',
        4 => 'QUAD DRAW',
        _ => 'RICOCHET RAMPAGE',
      };
}
