import 'package:deadbounce_flutter_app/features/game/engine/challenge/challenge_catalog.dart';
import 'package:deadbounce_flutter_app/features/game/engine/game_rng.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('same UTC date yields the same challenge worldwide', () {
    final seed = GameRng.dailySeed(DateTime.utc(2026, 6, 13));
    final a = ChallengeCatalog.forUtcDate('2026-06-13', seed);
    final b = ChallengeCatalog.forUtcDate('2026-06-13', seed);

    expect(a.name, b.name);
    expect(a.config.forcedEnemyType, b.config.forcedEnemyType);
    expect(a.config.scoreMultiplier, b.config.scoreMultiplier);
    expect(a.config.startingHearts, b.config.startingHearts);
    expect(a.config.extraWallDamage, b.config.extraWallDamage);
    expect(a.config.randomUpgrades, b.config.randomUpgrades);
  });

  test('a late offline submission still derives the same challenge', () {
    // The seed depends only on the calendar date, not the wall-clock time.
    final morning = GameRng.dailySeed(DateTime.utc(2026, 6, 13, 0, 1));
    final night = GameRng.dailySeed(DateTime.utc(2026, 6, 13, 23, 59));
    expect(morning, night);
    expect(
      ChallengeCatalog.forUtcDate('2026-06-13', morning).name,
      ChallengeCatalog.forUtcDate('2026-06-13', night).name,
    );
  });

  test('different dates can produce different challenges', () {
    final names = <String>{};
    for (var day = 1; day <= 30; day++) {
      final date = DateTime.utc(2026, 6, day);
      final seed = GameRng.dailySeed(date);
      names.add(ChallengeCatalog.forUtcDate('2026-06-$day', seed).name);
    }
    // Over a month the rotation should surface more than one template.
    expect(names.length, greaterThan(1));
  });

  test('golden: the seed for a fixed date never drifts', () {
    // A change here means every player\'s challenge silently shifted —
    // it must be deliberate.
    expect(
      GameRng.dailySeed(DateTime.utc(2026, 6, 13)),
      GameRng.fnv1a64('deadbounce-dc-2026-06-13'),
    );
  });
}
