import 'package:deadbounce_flutter_app/core/review/review_prompt_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // A fixed "now" so the cooldown math is deterministic.
  final base = DateTime(2026, 7, 4, 12);

  Future<ReviewPromptStore> makeStore({
    Map<String, Object> seed = const {},
    DateTime? now,
  }) async {
    SharedPreferences.setMockInitialValues(seed);
    final prefs = await SharedPreferences.getInstance();
    return ReviewPromptStore(prefs, now: () => now ?? base);
  }

  group('ReviewPromptStore.shouldPrompt', () {
    test('does not prompt before the minimum run count', () async {
      final store = await makeStore();
      expect(store.shouldPrompt(ReviewPromptStore.minRuns - 1), isFalse);
      expect(store.shouldPrompt(ReviewPromptStore.minRuns), isTrue);
    });

    test('does not prompt once opted out', () async {
      final store = await makeStore(seed: {'review_opted_out': true});
      expect(store.shouldPrompt(999), isFalse);
    });

    test('does not prompt past the lifetime cap', () async {
      final store = await makeStore(
        seed: {'review_prompt_count': ReviewPromptStore.maxPrompts},
      );
      expect(store.shouldPrompt(999), isFalse);
    });

    test('respects the cooldown between prompts', () async {
      final lastPrompted =
          base.subtract(ReviewPromptStore.cooldown - const Duration(days: 1));
      final tooSoon = await makeStore(
        seed: {'review_last_prompted_ms': lastPrompted.millisecondsSinceEpoch},
      );
      expect(tooSoon.shouldPrompt(999), isFalse);

      final elapsed =
          base.subtract(ReviewPromptStore.cooldown + const Duration(days: 1));
      final ready = await makeStore(
        seed: {'review_last_prompted_ms': elapsed.millisecondsSinceEpoch},
      );
      expect(ready.shouldPrompt(999), isTrue);
    });
  });

  group('ReviewPromptStore mutations', () {
    test('recordPrompted bumps count and stamps the time', () async {
      final store = await makeStore();
      expect(store.promptCount, 0);
      await store.recordPrompted();
      expect(store.promptCount, 1);
      // Immediately after recording we are inside the cooldown.
      expect(store.shouldPrompt(999), isFalse);
    });

    test('optOut permanently disables prompting', () async {
      final store = await makeStore();
      expect(store.shouldPrompt(ReviewPromptStore.minRuns), isTrue);
      await store.optOut();
      expect(store.optedOut, isTrue);
      expect(store.shouldPrompt(ReviewPromptStore.minRuns), isFalse);
    });
  });
}
