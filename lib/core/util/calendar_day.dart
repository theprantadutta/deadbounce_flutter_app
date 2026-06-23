/// yyyy-MM-dd helpers. The streak rule keys on the DEVICE-LOCAL date; the
/// daily challenge keys on the UTC date (so it's global). Keeping both
/// here makes the distinction explicit and testable.
abstract final class CalendarDay {
  static String _format(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Local calendar date of [at] (defaults to now).
  static String local([DateTime? at]) => _format(at ?? DateTime.now());

  /// UTC calendar date of [at] (defaults to now).
  static String utc([DateTime? at]) =>
      _format((at ?? DateTime.now()).toUtc());

  /// The local date one day before [date]'s local day.
  static String localYesterday([DateTime? at]) =>
      _format((at ?? DateTime.now()).subtract(const Duration(days: 1)));

  /// Parses a yyyy-MM-dd string to a local midnight DateTime, or null.
  static DateTime? parse(String date) {
    final parts = date.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  /// Whole-day difference [later] − [earlier] (both yyyy-MM-dd). Null when
  /// either fails to parse. The subtraction is done in UTC (which has no DST),
  /// so consecutive calendar days are always exactly 24h apart — otherwise a
  /// spring-forward day's 23h gap truncates to 0 and wrongly breaks the streak.
  static int? dayGap(String earlier, String later) {
    final a = parse(earlier);
    final b = parse(later);
    if (a == null || b == null) return null;
    final aUtc = DateTime.utc(a.year, a.month, a.day);
    final bUtc = DateTime.utc(b.year, b.month, b.day);
    return bUtc.difference(aUtc).inDays;
  }

  /// True when [candidate] is exactly the local day before [reference]'s
  /// local day — the streak-continues test.
  static bool isLocalYesterdayOf(String candidate, DateTime reference) =>
      dayGap(candidate, local(reference)) == 1;
}
