// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievements_dao.dart';

// ignore_for_file: type=lint
mixin _$AchievementsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AchievementStatesTable get achievementStates =>
      attachedDatabase.achievementStates;
  AchievementsDaoManager get managers => AchievementsDaoManager(this);
}

class AchievementsDaoManager {
  final _$AchievementsDaoMixin _db;
  AchievementsDaoManager(this._db);
  $$AchievementStatesTableTableManager get achievementStates =>
      $$AchievementStatesTableTableManager(
        _db.attachedDatabase,
        _db.achievementStates,
      );
}
