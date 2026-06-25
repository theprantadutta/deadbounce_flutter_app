import 'dart:math';

/// Full-jitter exponential backoff for outbox retries:
/// `min(10min, 5s * 2^attempts)` scaled by a random factor in [0.5, 1.0).
/// Pure function — unit-tested for bounds.
///
/// Transport failures now retry indefinitely (no attempt cap), so `attempts`
/// can grow large. The exponent is clamped before shifting so `5s * 2^n` can
/// never overflow a 64-bit int — the delay saturates at [capMs] by attempt ~7
/// anyway, so clamping well above that changes nothing but removes the overflow.
Duration syncBackoff(int attempts, Random random) {
  const baseMs = 5_000;
  const capMs = 600_000; // 10 minutes
  final exp = attempts.clamp(0, 20);
  final exponentialMs = min(capMs, baseMs * (1 << exp));
  final jittered = exponentialMs * (0.5 + random.nextDouble() * 0.5);
  return Duration(milliseconds: jittered.round());
}
