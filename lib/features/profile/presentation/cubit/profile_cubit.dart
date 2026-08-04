import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile_data.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileLoading());

  final ProfileRepository _repository;

  Future<void> load() async {
    emit(const ProfileLoading());
    await _fetch();
  }

  /// Reloads WITHOUT flashing the loading spinner — for in-place updates like
  /// the guest→linked flip, where the screen is already populated and blanking
  /// it would read as a glitch.
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    try {
      final profile = await _repository.getProfile();
      if (isClosed) return;
      emit(ProfileLoaded(profile));
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[profile] load failed');
      if (isClosed) return;
      emit(const ProfileError('Could not load your profile.'));
    }
  }
}
