import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';

part 'tournaments_state.dart';

/// Cache-first tournaments list: streams the local cache and refreshes from
/// the server in the background (offline-tolerant). Join/claim mutations live
/// in `tournament_actions.dart` (shared with the detail screen).
class TournamentsCubit extends Cubit<TournamentsState> {
  TournamentsCubit({required this._repository})
    : super(const TournamentsState()) {
    _sub = _repository.watchAll().listen((list) {
      emit(state.copyWith(tournaments: list, status: TournamentsStatus.ready));
    });
    refresh();
  }

  final TournamentRepository _repository;
  late final StreamSubscription<List<Tournament>> _sub;

  Future<void> refresh() async {
    emit(state.copyWith(refreshing: true));
    try {
      await _repository.refresh();
      if (isClosed) return;
      emit(state.copyWith(refreshing: false, offline: false));
    } on ApiException {
      if (isClosed) return;
      emit(state.copyWith(refreshing: false, offline: true));
    }
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
