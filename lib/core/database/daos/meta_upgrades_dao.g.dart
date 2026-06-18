// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_upgrades_dao.dart';

// ignore_for_file: type=lint
mixin _$MetaUpgradesDaoMixin on DatabaseAccessor<AppDatabase> {
  $MetaUpgradesTable get metaUpgrades => attachedDatabase.metaUpgrades;
  MetaUpgradesDaoManager get managers => MetaUpgradesDaoManager(this);
}

class MetaUpgradesDaoManager {
  final _$MetaUpgradesDaoMixin _db;
  MetaUpgradesDaoManager(this._db);
  $$MetaUpgradesTableTableManager get metaUpgrades =>
      $$MetaUpgradesTableTableManager(_db.attachedDatabase, _db.metaUpgrades);
}
