// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_dao.dart';

// ignore_for_file: type=lint
mixin _$TournamentDaoMixin on DatabaseAccessor<AppDatabase> {
  $TournamentsTable get tournaments => attachedDatabase.tournaments;
  $TournamentLeaderboardCacheTable get tournamentLeaderboardCache =>
      attachedDatabase.tournamentLeaderboardCache;
  TournamentDaoManager get managers => TournamentDaoManager(this);
}

class TournamentDaoManager {
  final _$TournamentDaoMixin _db;
  TournamentDaoManager(this._db);
  $$TournamentsTableTableManager get tournaments =>
      $$TournamentsTableTableManager(_db.attachedDatabase, _db.tournaments);
  $$TournamentLeaderboardCacheTableTableManager
  get tournamentLeaderboardCache =>
      $$TournamentLeaderboardCacheTableTableManager(
        _db.attachedDatabase,
        _db.tournamentLeaderboardCache,
      );
}
