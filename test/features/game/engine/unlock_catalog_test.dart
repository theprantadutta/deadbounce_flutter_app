import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import 'package:deadbounce_flutter_app/features/game/engine/arena/arena_catalog.dart';
import 'package:deadbounce_flutter_app/features/game/engine/game_rng.dart';
import 'package:deadbounce_flutter_app/features/game/engine/progression/unlock_catalog.dart';
import 'package:deadbounce_flutter_app/features/game/engine/upgrades/run_modifiers.dart';
import 'package:deadbounce_flutter_app/features/game/engine/upgrades/upgrade_catalog.dart';
import 'package:deadbounce_flutter_app/features/game/engine/upgrades/upgrade_deck.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(GameBalance.I.resetToDefaults);

  const fresh = UnlockStats(); // brand-new player: 0 everywhere

  test('the starting kit is always unlocked; new content is gated', () {
    // Originals (ungated) are unlocked from run 1.
    expect(UnlockCatalog.isCardUnlocked('quickdraw', fresh), isTrue);
    expect(UnlockCatalog.isArenaUnlocked('arena_clean', fresh), isTrue);

    // Phase-3 content is locked for a fresh player.
    expect(UnlockCatalog.isCardUnlocked('shrapnel', fresh), isFalse);
    expect(UnlockCatalog.isArenaUnlocked('arena_crossfire', fresh), isFalse);
  });

  test('crossing a milestone unlocks the content', () {
    // greased_lead unlocks at best wave 5.
    expect(
        UnlockCatalog.isCardUnlocked(
            'greased_lead', const UnlockStats(bestWave: 4)),
        isFalse);
    expect(
        UnlockCatalog.isCardUnlocked(
            'greased_lead', const UnlockStats(bestWave: 5)),
        isTrue);

    // shrapnel unlocks at 300 lifetime kills.
    expect(
        UnlockCatalog.isCardUnlocked(
            'shrapnel', const UnlockStats(lifetimeKills: 299)),
        isFalse);
    expect(
        UnlockCatalog.isCardUnlocked(
            'shrapnel', const UnlockStats(lifetimeKills: 300)),
        isTrue);
  });

  test('unlockedArenas is never empty and grows with progress', () {
    Set<String> ids(UnlockStats s) => UnlockCatalog.unlockedArenas(
        ArenaCatalog.all, (a) => a.id, s).map((a) => a.id).toSet();

    final early = ids(fresh);
    expect(early, containsAll(['arena_clean', 'arena_pillars', 'arena_angled']));
    expect(early, isNot(contains('arena_crossfire')));

    final veteran = ids(const UnlockStats(bestWave: 20, runsPlayed: 20));
    expect(veteran.length, ArenaCatalog.all.length); // everything is open
  });

  test('the draft never offers a locked card, but always the unlocked ones',
      () {
    final unlocked = UnlockCatalog.unlockedCardIds(
        UpgradeCatalog.all.map((c) => c.id), fresh);
    final rng = GameRng(7);
    for (var i = 0; i < 300; i++) {
      final draw = UpgradeDeck.draw3(rng, RunModifiers(),
          unlockedCardIds: unlocked);
      for (final card in draw) {
        expect(unlocked.contains(card.id), isTrue,
            reason: '${card.id} was locked but got drawn');
      }
    }
  });

  test('unlimited stats open everything (daily/tournament path)', () {
    final all = UnlockCatalog.unlockedCardIds(
        UpgradeCatalog.all.map((c) => c.id), UnlockStats.unlimited);
    expect(all.length, UpgradeCatalog.all.length);
  });
}
