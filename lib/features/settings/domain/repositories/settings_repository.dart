import '../entities/app_settings.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> load();
  Future<void> setSoundEnabled(bool enabled);
  Future<void> setHapticsEnabled(bool enabled);
}
