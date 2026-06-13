import 'package:flutter/services.dart';

/// Haptics behind the settings toggle. Uses the platform HapticFeedback
/// API — no extra dependency.
class HapticsService {
  HapticsService({bool enabled = true}) {
    _enabled = enabled;
  }

  late bool _enabled;

  // ignore: avoid_setters_without_getters
  set enabled(bool value) => _enabled = value;

  /// Firing a shot.
  void light() {
    if (_enabled) HapticFeedback.lightImpact();
  }

  /// A kill, a dash.
  void medium() {
    if (_enabled) HapticFeedback.mediumImpact();
  }

  /// Chains, Warden phase breaks, player damage.
  void heavy() {
    if (_enabled) HapticFeedback.heavyImpact();
  }
}
