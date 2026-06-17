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
    try {
      emit(ProfileLoaded(await _repository.getProfile()));
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[profile] load failed');
      emit(const ProfileError('Could not load your profile.'));
    }
  }
}
