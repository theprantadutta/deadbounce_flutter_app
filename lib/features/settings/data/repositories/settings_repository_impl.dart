import '../../../../core/database/app_database.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _soundKey = 'sound_enabled';
  static const _hapticsKey = 'haptics_enabled';

  @override
  Future<AppSettings> load() async {
    final sound = await _db.settingsDao.get(_soundKey);
    final haptics = await _db.settingsDao.get(_hapticsKey);
    return AppSettings(
      soundEnabled: sound != 'false', // default on
      hapticsEnabled: haptics != 'false',
    );
  }

  @override
  Future<void> setSoundEnabled(bool enabled) =>
      _db.settingsDao.set(_soundKey, enabled.toString());

  @override
  Future<void> setHapticsEnabled(bool enabled) =>
      _db.settingsDao.set(_hapticsKey, enabled.toString());
}
