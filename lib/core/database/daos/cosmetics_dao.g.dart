// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cosmetics_dao.dart';

// ignore_for_file: type=lint
mixin _$CosmeticsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CosmeticOwnedTable get cosmeticOwned => attachedDatabase.cosmeticOwned;
  $CosmeticEquippedTable get cosmeticEquipped =>
      attachedDatabase.cosmeticEquipped;
  CosmeticsDaoManager get managers => CosmeticsDaoManager(this);
}

class CosmeticsDaoManager {
  final _$CosmeticsDaoMixin _db;
  CosmeticsDaoManager(this._db);
  $$CosmeticOwnedTableTableManager get cosmeticOwned =>
      $$CosmeticOwnedTableTableManager(_db.attachedDatabase, _db.cosmeticOwned);
  $$CosmeticEquippedTableTableManager get cosmeticEquipped =>
      $$CosmeticEquippedTableTableManager(
        _db.attachedDatabase,
        _db.cosmeticEquipped,
      );
}
