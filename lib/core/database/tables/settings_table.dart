import 'package:drift/drift.dart';

/// Generic key-value settings store (sound, haptics, cached streak, ...).
@DataClassName('SettingRow')
class SettingsEntries extends Table {
  @override
  String get tableName => 'settings';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
