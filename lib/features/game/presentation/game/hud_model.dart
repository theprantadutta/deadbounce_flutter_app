import 'package:flutter/foundation.dart';

/// One drafted upgrade as the HUD tray needs it — pure data so this file
/// stays Flutter-widget-free. The icon name maps to a Material icon in the
/// presentation layer (reusing `UpgradePickerOverlay.iconFor`).
@immutable
class HudUpgrade {
  const HudUpgrade({
    required this.id,
    required this.name,
    required this.iconName,
    required this.stacks,
  });

  final String id;
  final String name;
  final String iconName;
  final int stacks;
}

/// High-frequency HUD values. The game mutates these notifiers directly
/// (at up to frame rate); the HUD listens per-value so only tiny widgets
/// rebuild. The cubit never emits at frame rate.
class HudModel {
  // --- Core stats (top command bar) ---
  final ValueNotifier<int> hearts = ValueNotifier(3);
  final ValueNotifier<int> maxHearts = ValueNotifier(3);
  final ValueNotifier<int> wave = ValueNotifier(0);
  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> coins = ValueNotifier(0);

  // --- Wave progress (center zone) ---
  /// Enemies still alive or pending this wave.
  final ValueNotifier<int> enemiesRemaining = ValueNotifier(0);

  /// Total enemies scheduled this wave (denominator for the progress bar).
  final ValueNotifier<int> enemiesTotal = ValueNotifier(0);

  // --- Chain / combo meter ---
  /// Length of the most recent live chain (1 = no chain yet). 0 = none active.
  final ValueNotifier<int> chainLength = ValueNotifier(0);

  /// Fraction (0..1) of the chain window remaining — the draining ring.
  /// Hits 0 when the chain lapses, which hides the meter.
  final ValueNotifier<double> chainRemaining = ValueNotifier(0);

  // --- Boss bar (Warden waves) ---
  final ValueNotifier<bool> bossActive = ValueNotifier(false);
  final ValueNotifier<String> bossName = ValueNotifier('');

  /// Phases already broken (0..phases). Drives the spent/remaining pips.
  final ValueNotifier<int> bossPhase = ValueNotifier(0);
  final ValueNotifier<int> bossPhases = ValueNotifier(0);
  final ValueNotifier<int> bossPhaseHp = ValueNotifier(0);
  final ValueNotifier<int> bossPhaseMaxHp = ValueNotifier(0);

  // --- Readiness (thumb zone) ---
  /// Fire-cooldown recharge fraction (0..1, 1 = ready) for the readiness pip.
  final ValueNotifier<double> fireCharge = ValueNotifier(1);

  /// False only during the brief dash snap.
  final ValueNotifier<bool> dashReady = ValueNotifier(true);

  // --- Drafted build (upgrade tray) ---
  final ValueNotifier<List<HudUpgrade>> activeUpgrades = ValueNotifier(
    const [],
  );

  void dispose() {
    hearts.dispose();
    maxHearts.dispose();
    wave.dispose();
    score.dispose();
    coins.dispose();
    enemiesRemaining.dispose();
    enemiesTotal.dispose();
    chainLength.dispose();
    chainRemaining.dispose();
    bossActive.dispose();
    bossName.dispose();
    bossPhase.dispose();
    bossPhases.dispose();
    bossPhaseHp.dispose();
    bossPhaseMaxHp.dispose();
    fireCharge.dispose();
    dashReady.dispose();
    activeUpgrades.dispose();
  }
}
