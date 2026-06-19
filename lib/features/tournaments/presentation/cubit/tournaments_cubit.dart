import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/sync/sync_worker.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';

part 'tournaments_state.dart';

/// Cache-first tournaments list: streams the local cache and refreshes from
/// the server in the background (offline-tolerant). Issues join/claim
/// mutations and nudges the sync engine.
class TournamentsCubit extends Cubit<TournamentsState> {
  TournamentsCubit({
    required this._repository,
    required this._syncWorker,
  }) : super(const TournamentsState()) {
    _sub = _repository.watchAll().listen((list) {
      emit(state.copyWith(
        tournaments: list,
        status: TournamentsStatus.ready,
      ));
    });
    refresh();
  }

  final TournamentRepository _repository;
  final SyncWorker _syncWorker;
  late final StreamSubscription<List<Tournament>> _sub;

  Future<void> refresh() async {
    emit(state.copyWith(refreshing: true));
    try {
      await _repository.refresh();
      emit(state.copyWith(refreshing: false, offline: false));
    } on ApiException {
      emit(state.copyWith(refreshing: false, offline: true));
    }
  }

  /// Returns null on success, or an error message to show.
  Future<String?> join(String id) async {
    try {
      await _repository.join(id);
      _syncWorker.requestSync();
      return null;
    } on TournamentException catch (e) {
      return e.message;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> claim(Tournament tournament) async {
    await _repository.claimReward(tournament);
    _syncWorker.requestSync();
  }

  Future<TournamentBoard> board(String id) => _repository.leaderboard(id);

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
