part of 'achievements_cubit.dart';

sealed class AchievementsState extends Equatable {
  const AchievementsState();

  @override
  List<Object?> get props => [];
}

final class AchievementsLoading extends AchievementsState {
  const AchievementsLoading();
}

final class AchievementsError extends AchievementsState {
  const AchievementsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class AchievementsLoaded extends AchievementsState {
  const AchievementsLoaded(this.views);
  final List<AchievementView> views;

  int get unlockedCount => views.where((v) => v.isUnlocked).length;
  int get claimableCount => views.where((v) => v.isClaimable).length;

  @override
  List<Object?> get props => [views];
}
