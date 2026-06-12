import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/daily_login_claims_table.dart';

part 'streak_dao.g.dart';

@DriftAccessor(tables: [DailyLoginClaims])
class StreakDao extends DatabaseAccessor<AppDatabase> with _$StreakDaoMixin {
  StreakDao(super.db);

  Future<DailyLoginClaimRow?> latestClaim() => (select(dailyLoginClaims)
        ..orderBy([(c) => OrderingTerm.desc(c.claimDate)])
        ..limit(1))
      .getSingleOrNull();

  Future<DailyLoginClaimRow?> getClaim(String localDate) =>
      (select(dailyLoginClaims)..where((c) => c.claimDate.equals(localDate)))
          .getSingleOrNull();

  Future<void> insertClaim(DailyLoginClaimRow row) =>
      into(dailyLoginClaims).insert(row);

  /// Most recent claims, newest first — enough to derive the current
  /// streak by walking consecutive dates.
  Future<List<DailyLoginClaimRow>> recentClaims({int limit = 14}) =>
      (select(dailyLoginClaims)
            ..orderBy([(c) => OrderingTerm.desc(c.claimDate)])
            ..limit(limit))
          .get();
}
