import 'package:deadbounce_flutter_app/core/config/game_balance.dart';

/// The 7-day login streak calendar: escalating coins, day 7 the big haul.
/// The cycle repeats (day 8 == day 1's reward) so a long streak keeps
/// paying out the week. The reward amounts live in
/// `GameBalance.I.economy.loginRewardsByDay` so they're panel-tunable.
abstract final class LoginRewards {
  static const int cycleLength = 7;

  /// Coins for a 1-based day index (wraps after 7).
  static int coinsForDay(int dayIndex) {
    final table = GameBalance.I.economy.loginRewardsByDay;
    final i = ((dayIndex - 1) % table.length).clamp(0, table.length - 1);
    return table[i];
  }

  /// 1-based position in the 7-day calendar for a streak length.
  static int calendarDay(int streak) => ((streak - 1) % cycleLength) + 1;
}
