import 'package:flutter_bloc/flutter_bloc.dart';

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
}
