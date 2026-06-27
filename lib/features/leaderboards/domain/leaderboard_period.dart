import 'entities/leaderboard_board.dart';

/// Client mirror of the backend's leaderboard period keys, so the cache can tell
/// "today's board" from a previous period's board after a UTC day / ISO-week /
/// challenge-date rollover. MUST stay bit-identical to the server's
/// `Deadbounce.Application/Features/Sync/Services/LeaderboardPeriod.cs`:
///   daily          → `yyyy-MM-dd` (UTC)
///   weekly         → `yyyy-Www`   (ISO-8601 week, year of the week's Thursday)
///   allTime        → `alltime`
///   dailyChallenge → `dc:yyyy-MM-dd` (today UTC; the server defaults the bare
///                    `/leaderboards/daily-challenge` path to today's date)
String leaderboardPeriodKey(LeaderboardTab tab, DateTime now) {
  final utc = now.toUtc();
  return switch (tab) {
    LeaderboardTab.daily => _dateKey(utc),
    LeaderboardTab.weekly =>
      '${_isoWeekYear(utc)}-W${_isoWeekNumber(utc).toString().padLeft(2, '0')}',
    LeaderboardTab.allTime => 'alltime',
    LeaderboardTab.dailyChallenge => 'dc:${_dateKey(utc)}',
  };
}

String _dateKey(DateTime utc) =>
    '${utc.year.toString().padLeft(4, '0')}-'
    '${utc.month.toString().padLeft(2, '0')}-'
    '${utc.day.toString().padLeft(2, '0')}';

/// ISO-8601 week number, matching .NET `System.Globalization.ISOWeek`: the week
/// belongs to the year of its Thursday, weeks start Monday.
int _isoWeekNumber(DateTime utc) {
  final d = DateTime.utc(utc.year, utc.month, utc.day);
  // Dart's weekday is already ISO (Mon=1..Sun=7).
  final thursday = d.add(Duration(days: 4 - d.weekday));
  final yearStart = DateTime.utc(thursday.year, 1, 1);
  return thursday.difference(yearStart).inDays ~/ 7 + 1;
}

/// The ISO week-numbering year (the year that owns the week's Thursday).
int _isoWeekYear(DateTime utc) {
  final d = DateTime.utc(utc.year, utc.month, utc.day);
  return d.add(Duration(days: 4 - d.weekday)).year;
}
