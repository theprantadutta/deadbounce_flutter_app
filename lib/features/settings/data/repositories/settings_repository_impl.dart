import '../../../../core/database/app_database.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _soundKey = 'sound_enabled';
  static const _hapticsKey = 'haptics_enabled';
  static const _musicKey = 'music_enabled';

  @override
  Future<AppSettings> load() async {
    final sound = await _db.settingsDao.get(_soundKey);
    final haptics = await _db.settingsDao.get(_hapticsKey);
    final music = await _db.settingsDao.get(_musicKey);
    return AppSettings(
      soundEnabled: sound != 'false', // default on
      hapticsEnabled: haptics != 'false',
      musicEnabled: music != 'false',
    );
  }

  @override
  Future<void> setSoundEnabled(bool enabled) =>
      _db.settingsDao.set(_soundKey, enabled.toString());

  @override
  Future<void> setHapticsEnabled(bool enabled) =>
      _db.settingsDao.set(_hapticsKey, enabled.toString());

  @override
  Future<void> setMusicEnabled(bool enabled) =>
      _db.settingsDao.set(_musicKey, enabled.toString());
}
