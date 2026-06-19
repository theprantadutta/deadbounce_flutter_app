import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/music_manager.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repository) : super(const AppSettings());

  final SettingsRepository _repository;

  Future<void> load() async {
    emit(await _repository.load());
  }

  Future<void> toggleSound(bool enabled) async {
    emit(state.copyWith(soundEnabled: enabled));
    await _repository.setSoundEnabled(enabled);
  }

  Future<void> toggleHaptics(bool enabled) async {
    emit(state.copyWith(hapticsEnabled: enabled));
    await _repository.setHapticsEnabled(enabled);
  }

  Future<void> toggleMusic(bool enabled) async {
    emit(state.copyWith(musicEnabled: enabled));
    MusicManager.instance.enabled = enabled;
    await _repository.setMusicEnabled(enabled);
  }

  Future<void> toggleScreenShake(bool enabled) async {
    emit(state.copyWith(screenShakeEnabled: enabled));
    await _repository.setScreenShakeEnabled(enabled);
  }

  Future<void> toggleHitStop(bool enabled) async {
    emit(state.copyWith(hitStopEnabled: enabled));
    await _repository.setHitStopEnabled(enabled);
  }

  Future<void> toggleAimGuide(bool enabled) async {
    emit(state.copyWith(aimGuideEnabled: enabled));
    await _repository.setAimGuideEnabled(enabled);
  }

  Future<void> toggleCombatText(bool enabled) async {
    emit(state.copyWith(combatTextEnabled: enabled));
    await _repository.setCombatTextEnabled(enabled);
  }

  Future<void> setParticleQuality(ParticleQuality quality) async {
    emit(state.copyWith(particleQuality: quality));
    await _repository.setParticleQuality(quality);
  }
}
