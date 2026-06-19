part of 'tournaments_cubit.dart';

enum TournamentsStatus { loading, ready }

class TournamentsState extends Equatable {
  const TournamentsState({
    this.status = TournamentsStatus.loading,
    this.tournaments = const [],
    this.refreshing = false,
    this.offline = false,
  });

  final TournamentsStatus status;
  final List<Tournament> tournaments;
  final bool refreshing;
  final bool offline;

  /// Active tournaments grouped by cadence, in daily→weekly→monthly order.
  Map<TournamentCadence, List<Tournament>> get byCadence {
    final map = <TournamentCadence, List<Tournament>>{};
    for (final cadence in TournamentCadence.values) {
      final group = tournaments.where((t) => t.cadence == cadence).toList()
        ..sort((a, b) => a.endsAt.compareTo(b.endsAt));
      if (group.isNotEmpty) map[cadence] = group;
    }
    return map;
  }

  TournamentsState copyWith({
    TournamentsStatus? status,
    List<Tournament>? tournaments,
    bool? refreshing,
    bool? offline,
  }) =>
      TournamentsState(
        status: status ?? this.status,
        tournaments: tournaments ?? this.tournaments,
        refreshing: refreshing ?? this.refreshing,
        offline: offline ?? this.offline,
      );

  @override
  List<Object?> get props => [status, tournaments, refreshing, offline];
}
