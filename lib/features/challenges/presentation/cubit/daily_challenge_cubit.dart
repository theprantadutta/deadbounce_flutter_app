import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/challenge_overview.dart';
import '../../domain/repositories/daily_challenge_repository.dart';

part 'daily_challenge_state.dart';

class DailyChallengeCubit extends Cubit<DailyChallengeState> {
  DailyChallengeCubit(this._repository)
      : super(const DailyChallengeLoading());

  final DailyChallengeRepository _repository;

  Future<void> load() async {
    emit(const DailyChallengeLoading());
    try {
      emit(DailyChallengeLoaded(await _repository.getTodaysChallenge()));
    } catch (_) {
      emit(const DailyChallengeFailure(
          "Couldn't load today's challenge. Try again."));
    }
  }
}
