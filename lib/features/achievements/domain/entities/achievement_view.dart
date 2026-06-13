import 'package:equatable/equatable.dart';

import '../achievement_catalog.dart';

/// An achievement plus the player's state, as the awards grid needs it.
class AchievementView extends Equatable {
  const AchievementView({
    required this.definition,
    required this.progress,
    required this.unlockedAt,
    required this.claimedAt,
  });

  final AchievementDefinition definition;
  final int progress;
  final DateTime? unlockedAt;
  final DateTime? claimedAt;

  bool get isUnlocked => unlockedAt != null;
  bool get isClaimed => claimedAt != null;

  /// Unlocked but the coin reward hasn't been collected yet.
  bool get isClaimable => isUnlocked && !isClaimed;

  /// Hidden until unlocked.
  bool get isHiddenSecret => definition.secret && !isUnlocked;

  double get progressFraction =>
      (progress / definition.target).clamp(0.0, 1.0);

  @override
  List<Object?> get props =>
      [definition.id, progress, unlockedAt, claimedAt];
}
