// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dao.dart';

// ignore_for_file: type=lint
mixin _$ProfileDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlayerProfilesTable get playerProfiles => attachedDatabase.playerProfiles;
  ProfileDaoManager get managers => ProfileDaoManager(this);
}

class ProfileDaoManager {
  final _$ProfileDaoMixin _db;
  ProfileDaoManager(this._db);
  $$PlayerProfilesTableTableManager get playerProfiles =>
      $$PlayerProfilesTableTableManager(
        _db.attachedDatabase,
        _db.playerProfiles,
      );
}
