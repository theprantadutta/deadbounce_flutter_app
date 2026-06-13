import 'package:equatable/equatable.dart';

/// The player's login-streak standing, as the UI needs it.
class StreakState extends Equatable {
  const StreakState({
    required this.currentStreak,
    required this.canClaimToday,
    required this.todayCalendarDay,
    required this.todayReward,
  });

  /// Consecutive days claimed (0 before the first claim ever).
  final int currentStreak;

  /// False once today's reward has been claimed.
  final bool canClaimToday;

  /// 1-based position in the 7-day calendar today's claim would land on.
  final int todayCalendarDay;

  /// Coins today's claim would grant.
  final int todayReward;

  @override
  List<Object?> get props =>
      [currentStreak, canClaimToday, todayCalendarDay, todayReward];
}

/// Result of a successful claim — drives the reward modal.
class StreakClaimResult extends Equatable {
  const StreakClaimResult({
    required this.calendarDay,
    required this.coinsAwarded,
    required this.newStreak,
  });

  final int calendarDay;
  final int coinsAwarded;
  final int newStreak;

  @override
  List<Object?> get props => [calendarDay, coinsAwarded, newStreak];
}
