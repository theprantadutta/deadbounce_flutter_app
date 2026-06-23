import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/streak_state.dart';
import '../../domain/repositories/login_streak_repository.dart';

part 'daily_reward_state.dart';

class DailyRewardCubit extends Cubit<DailyRewardState> {
  DailyRewardCubit(this._repository) : super(const DailyRewardLoading());

  final LoginStreakRepository _repository;

  Future<void> load() async {
    emit(const DailyRewardLoading());
    try {
      final streak = await _repository.getState();
      if (isClosed) return;
      emit(DailyRewardReady(streak));
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[streak] load failed');
      if (isClosed) return;
      emit(const DailyRewardError('Could not load your streak.'));
    }
  }

  Future<void> claim() async {
    final current = state;
    if (current is! DailyRewardReady || !current.streak.canClaimToday) return;
    emit(DailyRewardClaiming(current.streak));
    try {
      final result = await _repository.claimToday();
      final refreshed = await _repository.getState();
      if (isClosed) return;
      emit(DailyRewardClaimed(refreshed, result));
    } on AlreadyClaimedToday {
      final refreshed = await _repository.getState();
      if (isClosed) return;
      emit(DailyRewardReady(refreshed));
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[streak] claim failed');
      if (isClosed) return;
      emit(DailyRewardReady(current.streak));
    }
  }
}
