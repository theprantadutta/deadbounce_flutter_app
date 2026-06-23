import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/challenge_overview.dart';
import '../../domain/repositories/daily_challenge_repository.dart';

part 'daily_challenge_state.dart';

class DailyChallengeCubit extends Cubit<DailyChallengeState> {
  DailyChallengeCubit(this._repository) : super(const DailyChallengeLoading());

  final DailyChallengeRepository _repository;

  Future<void> load() async {
    emit(const DailyChallengeLoading());
    try {
      final overview = await _repository.getTodaysChallenge();
      if (isClosed) return;
      emit(DailyChallengeLoaded(overview));
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[challenge] load failed');
      if (isClosed) return;
      emit(
        const DailyChallengeFailure(
          "Couldn't load today's challenge. Try again.",
        ),
      );
    }
  }
}
