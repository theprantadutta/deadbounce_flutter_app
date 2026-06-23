import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../leaderboards/domain/entities/leaderboard_board.dart';
import '../../../leaderboards/domain/repositories/leaderboard_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../statistics/domain/repositories/statistics_repository.dart';
import '../../domain/entities/home_summary.dart';

part 'home_state.dart';

/// Loads the home screen's personalized summary from local Drift (offline-
/// first): profile identity, lifetime bests, and the cached all-time rank.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required ProfileRepository profileRepository,
    required StatisticsRepository statisticsRepository,
    required LeaderboardRepository leaderboardRepository,
  }) : _profile = profileRepository,
       _stats = statisticsRepository,
       _leaderboard = leaderboardRepository,
       super(const HomeLoading());

  final ProfileRepository _profile;
  final StatisticsRepository _stats;
  final LeaderboardRepository _leaderboard;

  Future<void> load() async {
    try {
      final profile = await _profile.getProfile();
      final stats = await _stats.getStatistics();

      // Rank is best-effort — null when the board was never synced.
      int? rank;
      try {
        final board = await _leaderboard.getCached(LeaderboardTab.allTime);
        rank = board?.playerRank;
      } catch (e, st) {
        AppLogger.talker.handle(e, st, '[home] cached rank lookup failed');
      }

      if (isClosed) return;
      emit(
        HomeLoaded(
          HomeSummary(
            displayName: profile.displayName,
            isGuest: profile.isGuest,
            bestScore: stats.bestScore,
            totalKills: stats.totalKills,
            rank: rank,
          ),
        ),
      );
    } catch (e, st) {
      // Never block the menu — fall back to an empty summary.
      AppLogger.talker.handle(e, st, '[home] summary load failed');
      if (isClosed) return;
      emit(const HomeLoaded(HomeSummary.empty()));
    }
  }
}
