/// Deterministic RNG for gameplay. Hand-rolled xorshift64* — NOT
/// dart:math's Random — so sequences are bit-stable across platforms,
/// which the daily challenge depends on (same date, same challenge,
/// worldwide, offline).
///
/// Systems each get their own named [fork] (spawn / waves / upgrades /
/// loot / modifiers / enemyAi) so consuming from one stream can never
/// shift another. VFX must use an unseeded dart:math Random instead —
/// juice should never burn gameplay entropy.
class GameRng {
  GameRng(int seed) : _state = _mix(seed == 0 ? 0x9E3779B97F4A7C15 : seed);

  /// Daily-challenge seed: identical for every player on a UTC date.
  factory GameRng.daily(DateTime utcDate) =>
      GameRng(dailySeed(utcDate));

  static int dailySeed(DateTime utcDate) {
    final d = utcDate.toUtc();
    final key = 'deadbounce-dc-${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    return fnv1a64(key);
  }

  int _state;

  /// FNV-1a 64-bit over UTF-16 code units — stable, allocation-free.
  static int fnv1a64(String input) {
    var hash = 0xcbf29ce484222325;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash;
  }

  static int _mix(int x) {
    // splitmix64 finalizer — turns any seed into a well-distributed state.
    x = (x + 0x9E3779B97F4A7C15) & 0xFFFFFFFFFFFFFFFF;
    x = ((x ^ (x >>> 30)) * 0xBF58476D1CE4E5B9) & 0xFFFFFFFFFFFFFFFF;
    x = ((x ^ (x >>> 27)) * 0x94D049BB133111EB) & 0xFFFFFFFFFFFFFFFF;
    return x ^ (x >>> 31);
  }

  int _next() {
    var x = _state;
    x ^= (x << 13) & 0xFFFFFFFFFFFFFFFF;
    x ^= x >>> 7;
    x ^= (x << 17) & 0xFFFFFFFFFFFFFFFF;
    _state = x;
    return (x * 0x2545F4914F6CDD1D) & 0xFFFFFFFFFFFFFFFF;
  }

  /// Child generator whose stream is independent of this one's future use.
  GameRng fork(String label) =>
      GameRng(_mix(_state ^ fnv1a64(label)));

  /// Uniform double in [0, 1).
  double nextDouble() => (_next() >>> 11) / 9007199254740992.0; // 2^53

  /// Uniform int in [0, max).
  int nextInt(int max) {
    assert(max > 0);
    return (nextDouble() * max).floor();
  }

  bool chance(double p) => nextDouble() < p;

  /// Uniform double in [min, max).
  double range(double min, double max) => min + nextDouble() * (max - min);

  /// Picks one element.
  T pick<T>(List<T> items) => items[nextInt(items.length)];
}
