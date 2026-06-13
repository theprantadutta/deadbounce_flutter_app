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
      emit(DailyRewardReady(streak));
    } catch (_) {
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
      emit(DailyRewardClaimed(refreshed, result));
    } on AlreadyClaimedToday {
      emit(DailyRewardReady(await _repository.getState()));
    } catch (_) {
      emit(DailyRewardReady(current.streak));
    }
  }
}
