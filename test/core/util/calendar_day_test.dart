import 'package:deadbounce_flutter_app/core/util/calendar_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarDay.dayGap', () {
    test('consecutive calendar days are always a gap of 1', () {
      // US spring-forward (2026-03-08) and fall-back (2026-11-01) days: the
      // local wall-clock gap to the next midnight is 23h/25h, but the calendar
      // gap must still be exactly 1 (the fix subtracts in UTC).
      expect(CalendarDay.dayGap('2026-03-08', '2026-03-09'), 1);
      expect(CalendarDay.dayGap('2026-11-01', '2026-11-02'), 1);
      expect(CalendarDay.dayGap('2026-06-20', '2026-06-21'), 1);
    });

    test('same day is 0, month/year rollovers are correct', () {
      expect(CalendarDay.dayGap('2026-06-20', '2026-06-20'), 0);
      expect(CalendarDay.dayGap('2026-01-31', '2026-02-01'), 1);
      expect(CalendarDay.dayGap('2025-12-31', '2026-01-01'), 1);
      expect(CalendarDay.dayGap('2026-06-20', '2026-06-27'), 7);
    });

    test('a gap (not yesterday) is > 1, so the streak resets', () {
      expect(CalendarDay.dayGap('2026-06-01', '2026-06-30'), 29);
    });

    test('returns null on unparseable input', () {
      expect(CalendarDay.dayGap('nope', '2026-06-20'), isNull);
    });
  });
}
