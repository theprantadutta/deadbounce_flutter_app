// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_cache_dao.dart';

// ignore_for_file: type=lint
mixin _$LeaderboardCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $LeaderboardCacheEntriesTable get leaderboardCacheEntries =>
      attachedDatabase.leaderboardCacheEntries;
  $LeaderboardSyncMetaTable get leaderboardSyncMeta =>
      attachedDatabase.leaderboardSyncMeta;
  LeaderboardCacheDaoManager get managers => LeaderboardCacheDaoManager(this);
}

class LeaderboardCacheDaoManager {
  final _$LeaderboardCacheDaoMixin _db;
  LeaderboardCacheDaoManager(this._db);
  $$LeaderboardCacheEntriesTableTableManager get leaderboardCacheEntries =>
      $$LeaderboardCacheEntriesTableTableManager(
        _db.attachedDatabase,
        _db.leaderboardCacheEntries,
      );
  $$LeaderboardSyncMetaTableTableManager get leaderboardSyncMeta =>
      $$LeaderboardSyncMetaTableTableManager(
        _db.attachedDatabase,
        _db.leaderboardSyncMeta,
      );
}
