import '../entities/game_statistics.dart';

abstract interface class StatisticsRepository {
  Future<GameStatistics> getStatistics();
}
