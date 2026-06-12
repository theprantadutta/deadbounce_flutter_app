import 'dart:math';

/// Full-jitter exponential backoff for outbox retries:
/// `min(10min, 5s * 2^attempts)` scaled by a random factor in [0.5, 1.0).
/// Pure function — unit-tested for bounds.
Duration syncBackoff(int attempts, Random random) {
  const baseMs = 5_000;
  const capMs = 600_000; // 10 minutes
  final exponentialMs = min(capMs, baseMs * pow(2, attempts)).toDouble();
  final jittered = exponentialMs * (0.5 + random.nextDouble() * 0.5);
  return Duration(milliseconds: jittered.round());
}
