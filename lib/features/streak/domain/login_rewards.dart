/// The 7-day login streak calendar: escalating coins, day 7 the big haul.
/// The cycle repeats (day 8 == day 1's reward) so a long streak keeps
/// paying out the week.
abstract final class LoginRewards {
  static const List<int> coinsByDay = [25, 40, 60, 80, 110, 150, 300];

  static const int cycleLength = 7;

  /// Coins for a 1-based day index (wraps after 7).
  static int coinsForDay(int dayIndex) {
    final i = ((dayIndex - 1) % cycleLength).clamp(0, cycleLength - 1);
    return coinsByDay[i];
  }

  /// 1-based position in the 7-day calendar for a streak length.
  static int calendarDay(int streak) => ((streak - 1) % cycleLength) + 1;
}
