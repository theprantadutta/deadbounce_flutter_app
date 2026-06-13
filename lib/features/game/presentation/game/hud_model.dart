import 'package:flutter/foundation.dart';

/// High-frequency HUD values. The game mutates these notifiers directly
/// (at up to frame rate); HudOverlay listens per-value so only tiny text
/// widgets rebuild. The cubit never emits at frame rate.
class HudModel {
  final ValueNotifier<int> hearts = ValueNotifier(3);
  final ValueNotifier<int> maxHearts = ValueNotifier(3);
  final ValueNotifier<int> wave = ValueNotifier(0);
  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> coins = ValueNotifier(0);
  final ValueNotifier<bool> fireReady = ValueNotifier(true);

  void dispose() {
    hearts.dispose();
    maxHearts.dispose();
    wave.dispose();
    score.dispose();
    coins.dispose();
    fireReady.dispose();
  }
}
