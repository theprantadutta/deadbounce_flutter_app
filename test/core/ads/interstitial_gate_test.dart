import 'package:deadbounce_flutter_app/core/ads/interstitial_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 8, 4, 12);

  InterstitialGate readyGate() {
    final gate = InterstitialGate();
    // Satisfy the runs-since-last rule.
    for (var i = 0; i < 4; i++) {
      gate.recordRunFinished();
    }
    return gate;
  }

  bool ask(
    InterstitialGate gate, {
    DateTime? at,
    int lifetimeRuns = 50,
    bool isNormalRun = true,
    bool sessionEnding = false,
    bool adsRemoved = false,
  }) =>
      gate.shouldShow(
        now: at ?? now,
        lifetimeRuns: lifetimeRuns,
        isNormalRun: isNormalRun,
        sessionEnding: sessionEnding,
        adsRemoved: adsRemoved,
      );

  test('shows once every rule is satisfied', () {
    expect(ask(readyGate()), isTrue);
  });

  group('each rule blocks on its own', () {
    test('a paid no-ads entitlement blocks it', () {
      expect(ask(readyGate(), adsRemoved: true), isFalse);
    });

    test('onboarding is protected — no interstitial in the first runs', () {
      expect(ask(readyGate(), lifetimeRuns: 4), isFalse);
      expect(ask(readyGate(), lifetimeRuns: 5), isTrue);
    });

    test('never during a tournament or daily challenge', () {
      // Competitive, seeded runs — an ad mid-contest is the worst moment.
      expect(ask(readyGate(), isNormalRun: false), isFalse);
    });

    test('never on the way out of a session', () {
      expect(ask(readyGate(), sessionEnding: true), isFalse);
    });

    test('not before enough runs have passed', () {
      final gate = InterstitialGate();
      gate.recordRunFinished();
      gate.recordRunFinished();
      gate.recordRunFinished();
      expect(ask(gate), isFalse);

      gate.recordRunFinished();
      expect(ask(gate), isTrue);
    });
  });

  group('pacing after one is shown', () {
    test('the run counter resets, so four more runs are needed', () {
      final gate = readyGate();
      gate.recordInterstitialShown(now);

      expect(gate.runsSinceLast, 0);
      // Even far in the future, the run count still gates it.
      expect(ask(gate, at: now.add(const Duration(hours: 5))), isFalse);
    });

    test('the time gap gates it even when runs are plentiful', () {
      final gate = readyGate();
      gate.recordInterstitialShown(now);
      for (var i = 0; i < 10; i++) {
        gate.recordRunFinished();
      }

      expect(ask(gate, at: now.add(const Duration(minutes: 2))), isFalse);
      expect(ask(gate, at: now.add(const Duration(minutes: 4))), isTrue);
    });
  });

  group('rewarded cooldown', () {
    test('watching a rewarded ad suppresses interstitials for a day', () {
      // Someone who opts in has already paid attention. Taxing them again is
      // how you train players to stop opting in — and rewarded ads are the
      // ones that actually carry the revenue.
      final gate = readyGate();
      gate.recordRewardedWatched(now);

      expect(ask(gate, at: now.add(const Duration(hours: 1))), isFalse);
      expect(ask(gate, at: now.add(const Duration(hours: 23))), isFalse);
      expect(ask(gate, at: now.add(const Duration(hours: 25))), isTrue);
    });
  });

  test('a fresh gate never fires immediately', () {
    // No runs recorded yet — the very first run must not end in an ad.
    expect(ask(InterstitialGate()), isFalse);
  });
}
