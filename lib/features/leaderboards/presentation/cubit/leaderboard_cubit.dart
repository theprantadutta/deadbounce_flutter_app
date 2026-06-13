import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/leaderboard_board.dart';
import '../../domain/repositories/leaderboard_repository.dart';

part 'leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit(this._repository)
      : super(const LeaderboardState.initial());

  final LeaderboardRepository _repository;

  /// Loads a tab cache-first, then refreshes from the network in the
  /// background. The cached standings show instantly (with a "last synced"
  /// stamp); a failed refresh leaves the cache in place.
  Future<void> selectTab(LeaderboardTab tab) async {
    if (state.tab == tab && state.board != null) {
      // Already showing this tab; just re-refresh quietly.
      await _refresh(tab);
      return;
    }

    final cached = await _repository.getCached(tab);
    emit(state.copyWith(
      tab: tab,
      board: cached,
      status: cached == null
          ? LeaderboardStatus.loading
          : LeaderboardStatus.ready,
      refreshing: true,
      clearError: true,
    ));

    await _refresh(tab);
  }

  Future<void> _refresh(LeaderboardTab tab) async {
    try {
      final fresh = await _repository.refresh(tab);
      if (state.tab != tab) return; // user switched away mid-fetch
      emit(state.copyWith(
        board: fresh,
        status: LeaderboardStatus.ready,
        refreshing: false,
        clearError: true,
      ));
    } catch (_) {
      if (state.tab != tab) return;
      emit(state.copyWith(
        status: state.board == null
            ? LeaderboardStatus.error
            : LeaderboardStatus.ready,
        refreshing: false,
        error: state.board == null
            ? 'No connection — and nothing cached yet.'
            : null,
      ));
    }
  }
}
