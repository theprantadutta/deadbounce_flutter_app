import 'package:deadbounce_flutter_app/features/game/engine/game_rng.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('same seed produces identical sequences', () {
    final a = GameRng(12345);
    final b = GameRng(12345);
    for (var i = 0; i < 1000; i++) {
      expect(a.nextDouble(), b.nextDouble());
    }
  });

  test('different seeds diverge', () {
    final a = GameRng(1);
    final b = GameRng(2);
    var same = 0;
    for (var i = 0; i < 100; i++) {
      if (a.nextInt(1000) == b.nextInt(1000)) same++;
    }
    expect(same, lessThan(5));
  });

  test('forks are independent of parent consumption', () {
    final parent1 = GameRng(99);
    final fork1 = parent1.fork('spawn');
    final firstValues = [for (var i = 0; i < 10; i++) fork1.nextDouble()];

    final parent2 = GameRng(99);
    final fork2 = parent2.fork('spawn');
    final secondValues = [for (var i = 0; i < 10; i++) fork2.nextDouble()];

    expect(firstValues, secondValues);

    // Consuming a differently-labeled fork doesn't shift this one.
    final parent3 = GameRng(99);
    parent3.fork('upgrades').nextDouble();
    final fork3 = parent3.fork('spawn');
    expect(fork3.nextDouble(), firstValues.first);
  });

  test('daily seed is stable for a fixed date and differs across dates',
      () {
    final a = GameRng.dailySeed(DateTime.utc(2026, 6, 12));
    final b = GameRng.dailySeed(DateTime.utc(2026, 6, 12, 23, 59));
    final c = GameRng.dailySeed(DateTime.utc(2026, 6, 13));
    expect(a, b);
    expect(a, isNot(c));

    // Golden value: pin the seed so an accidental hash change (which
    // would silently change everyone's challenge) fails loudly.
    expect(a, GameRng.fnv1a64('deadbounce-dc-2026-06-12'));
  });

  test('nextInt stays in range and chance is sane', () {
    final rng = GameRng(7);
    for (var i = 0; i < 1000; i++) {
      final v = rng.nextInt(10);
      expect(v, inInclusiveRange(0, 9));
    }
    var hits = 0;
    for (var i = 0; i < 10000; i++) {
      if (rng.chance(0.1)) hits++;
    }
    expect(hits, inInclusiveRange(800, 1200));
  });
}
