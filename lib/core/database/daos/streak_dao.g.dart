// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_dao.dart';

// ignore_for_file: type=lint
mixin _$StreakDaoMixin on DatabaseAccessor<AppDatabase> {
  $DailyLoginClaimsTable get dailyLoginClaims =>
      attachedDatabase.dailyLoginClaims;
  StreakDaoManager get managers => StreakDaoManager(this);
}

class StreakDaoManager {
  final _$StreakDaoMixin _db;
  StreakDaoManager(this._db);
  $$DailyLoginClaimsTableTableManager get dailyLoginClaims =>
      $$DailyLoginClaimsTableTableManager(
        _db.attachedDatabase,
        _db.dailyLoginClaims,
      );
}
