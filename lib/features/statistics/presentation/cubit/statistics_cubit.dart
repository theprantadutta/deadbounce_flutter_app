import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/game_statistics.dart';
import '../../domain/repositories/statistics_repository.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit(this._repository) : super(const StatisticsLoading());

  final StatisticsRepository _repository;

  Future<void> load() async {
    emit(const StatisticsLoading());
    try {
      final stats = await _repository.getStatistics();
      if (isClosed) return;
      emit(StatisticsLoaded(stats));
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[stats] load failed');
      if (isClosed) return;
      emit(const StatisticsError('Could not load your statistics.'));
    }
  }
}
