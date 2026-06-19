import '../../../../core/database/app_database.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _soundKey = 'sound_enabled';
  static const _hapticsKey = 'haptics_enabled';
  static const _musicKey = 'music_enabled';
  static const _screenShakeKey = 'screen_shake_enabled';
  static const _hitStopKey = 'hit_stop_enabled';
  static const _aimGuideKey = 'aim_guide_enabled';
  static const _combatTextKey = 'combat_text_enabled';
  static const _particleQualityKey = 'particle_quality';

  @override
  Future<AppSettings> load() async {
    final sound = await _db.settingsDao.get(_soundKey);
    final haptics = await _db.settingsDao.get(_hapticsKey);
    final music = await _db.settingsDao.get(_musicKey);
    final screenShake = await _db.settingsDao.get(_screenShakeKey);
    final hitStop = await _db.settingsDao.get(_hitStopKey);
    final aimGuide = await _db.settingsDao.get(_aimGuideKey);
    final combatText = await _db.settingsDao.get(_combatTextKey);
    final particleQuality = await _db.settingsDao.get(_particleQualityKey);
    return AppSettings(
      soundEnabled: sound != 'false', // default on
      hapticsEnabled: haptics != 'false',
      musicEnabled: music != 'false',
      screenShakeEnabled: screenShake != 'false',
      hitStopEnabled: hitStop != 'false',
      aimGuideEnabled: aimGuide != 'false',
      combatTextEnabled: combatText != 'false',
      particleQuality: ParticleQuality.fromName(particleQuality),
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

  @override
  Future<void> setScreenShakeEnabled(bool enabled) =>
      _db.settingsDao.set(_screenShakeKey, enabled.toString());

  @override
  Future<void> setHitStopEnabled(bool enabled) =>
      _db.settingsDao.set(_hitStopKey, enabled.toString());

  @override
  Future<void> setAimGuideEnabled(bool enabled) =>
      _db.settingsDao.set(_aimGuideKey, enabled.toString());

  @override
  Future<void> setCombatTextEnabled(bool enabled) =>
      _db.settingsDao.set(_combatTextKey, enabled.toString());

  @override
  Future<void> setParticleQuality(ParticleQuality quality) =>
      _db.settingsDao.set(_particleQualityKey, quality.name);
}
