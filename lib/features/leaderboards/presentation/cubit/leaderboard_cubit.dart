import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/leaderboard_board.dart';
import '../../domain/repositories/leaderboard_repository.dart';

part 'leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit(this._repository) : super(const LeaderboardState.initial());

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
    if (isClosed) return;
    emit(
      state.copyWith(
        tab: tab,
        board: cached,
        status: cached == null
            ? LeaderboardStatus.loading
            : LeaderboardStatus.ready,
        refreshing: true,
        clearError: true,
      ),
    );

    await _refresh(tab);
  }

  Future<void> _refresh(LeaderboardTab tab) async {
    try {
      final fresh = await _repository.refresh(tab);
      if (isClosed || state.tab != tab) return; // closed or switched away
      emit(
        state.copyWith(
          board: fresh,
          status: LeaderboardStatus.ready,
          refreshing: false,
          offline: false,
          clearError: true,
        ),
      );
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[leaderboard] load failed');
      if (isClosed || state.tab != tab) return;
      final hasCache = state.board != null;
      // Offline: keep the cached board up (flagged stale) rather than erroring;
      // only a board we never cached shows the empty/error state.
      emit(
        state.copyWith(
          status:
              hasCache ? LeaderboardStatus.ready : LeaderboardStatus.error,
          refreshing: false,
          offline: true,
          error: hasCache ? null : 'No connection — and nothing cached yet.',
          clearError: hasCache,
        ),
      );
    }
  }
}
