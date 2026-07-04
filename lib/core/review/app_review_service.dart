import 'package:in_app_review/in_app_review.dart';

import '../logging/app_logger.dart';
import 'review_prompt_store.dart';

/// Seam over Google Play's in-app review flow + store listing.
///
/// Gameplay/UI code depends on this interface; the [InAppReviewService] impl
/// wraps the `in_app_review` plugin. Failures are swallowed (a review is never
/// worth crashing a run over) — mirrors the [SoundManager] seam's approach.
abstract interface class AppReviewService {
  /// Opens the app's store listing so the user can leave a rating/review.
  /// Backs the explicit "Rate Deadbounce" button in Settings.
  Future<void> openStoreListing();

  /// Shows the native in-app review sheet IF the throttle allows it
  /// ([ReviewPromptStore.shouldPrompt]). A no-op otherwise — safe to call after
  /// every run.
  Future<void> maybePromptReview({required int runsPlayed});
}

class InAppReviewService implements AppReviewService {
  InAppReviewService(this._promptStore, {InAppReview? review})
      : _review = review ?? InAppReview.instance;

  final ReviewPromptStore _promptStore;
  final InAppReview _review;

  @override
  Future<void> openStoreListing() async {
    try {
      await _review.openStoreListing();
      // They went to rate manually — don't also nag with the native prompt.
      await _promptStore.optOut();
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[review] openStoreListing failed');
    }
  }

  @override
  Future<void> maybePromptReview({required int runsPlayed}) async {
    if (!_promptStore.shouldPrompt(runsPlayed)) return;
    try {
      if (!await _review.isAvailable()) return;
      // Record before requesting: Play may silently no-op (already reviewed /
      // quota spent) without telling us, so count it as an attempt either way
      // to honour our own cooldown.
      await _promptStore.recordPrompted();
      await _review.requestReview();
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[review] requestReview failed');
    }
  }
}
