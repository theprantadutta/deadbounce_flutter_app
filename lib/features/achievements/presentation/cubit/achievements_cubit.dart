import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/sync/sync_worker.dart';
import '../../domain/entities/achievement_view.dart';
import '../../domain/repositories/achievements_repository.dart';

part 'achievements_state.dart';

class AchievementsCubit extends Cubit<AchievementsState> {
  AchievementsCubit({
    required this._repository,
    required this._syncWorker,
  }) : super(const AchievementsLoading());

  final AchievementsRepository _repository;
  final SyncWorker _syncWorker;
  StreamSubscription<List<AchievementView>>? _sub;

  void load() {
    emit(const AchievementsLoading());
    _sub?.cancel();
    _sub = _repository.watchAll().listen(
      (views) => emit(AchievementsLoaded(views)),
      onError: (_) =>
          emit(const AchievementsError('Could not load your awards.')),
    );
  }

  Future<void> claim(String achievementId) async {
    await _repository.claim(achievementId);
    _syncWorker.requestSync();
    // The watchAll stream pushes the refreshed list automatically.
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
