import 'dart:math';

import 'package:deadbounce_flutter_app/core/sync/backoff.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('backoff grows exponentially within full-jitter bounds', () {
    final random = Random(7);
    for (var attempts = 0; attempts < 12; attempts++) {
      final expectedCeiling = min(600_000, 5_000 * pow(2, attempts)).toDouble();
      for (var i = 0; i < 50; i++) {
        final delay = syncBackoff(attempts, random).inMilliseconds;
        expect(delay, greaterThanOrEqualTo((expectedCeiling * 0.5).floor()),
            reason: 'attempt $attempts produced $delay below jitter floor');
        expect(delay, lessThanOrEqualTo(expectedCeiling.ceil()),
            reason: 'attempt $attempts produced $delay above ceiling');
      }
    }
  });

  test('backoff caps at 10 minutes', () {
    final random = Random(7);
    for (var i = 0; i < 100; i++) {
      expect(
        syncBackoff(30, random).inMilliseconds,
        lessThanOrEqualTo(600_000),
      );
    }
  });
}
