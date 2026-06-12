import 'package:drift/drift.dart';

/// One row per claimed daily-login reward. claimDate is the DEVICE-LOCAL
/// calendar date (yyyy-MM-dd) at claim time — see the streak rule in
/// CLAUDE.md. Streak state is derived from consecutive trailing dates.
@DataClassName('DailyLoginClaimRow')
class DailyLoginClaims extends Table {
  TextColumn get claimDate => text()();

  /// 1..7 position in the streak calendar (wraps after day 7).
  IntColumn get dayIndex => integer()();
  IntColumn get coinsAwarded => integer()();
  IntColumn get claimedAt => integer()();

  @override
  Set<Column> get primaryKey => {claimDate};
}
