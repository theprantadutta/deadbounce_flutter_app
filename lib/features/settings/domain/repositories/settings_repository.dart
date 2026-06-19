import '../entities/app_settings.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> load();
  Future<void> setSoundEnabled(bool enabled);
  Future<void> setHapticsEnabled(bool enabled);
  Future<void> setMusicEnabled(bool enabled);
  Future<void> setScreenShakeEnabled(bool enabled);
  Future<void> setHitStopEnabled(bool enabled);
  Future<void> setAimGuideEnabled(bool enabled);
  Future<void> setCombatTextEnabled(bool enabled);
  Future<void> setParticleQuality(ParticleQuality quality);
}
