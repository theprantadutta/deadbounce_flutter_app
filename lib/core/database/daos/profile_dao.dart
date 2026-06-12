import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/player_profile_table.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [PlayerProfiles])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Future<PlayerProfileRow?> getProfile() =>
      (select(playerProfiles)..where((p) => p.id.equals(0))).getSingleOrNull();

  Stream<PlayerProfileRow?> watchProfile() =>
      (select(playerProfiles)..where((p) => p.id.equals(0)))
          .watchSingleOrNull();

  Future<void> upsertProfile(PlayerProfilesCompanion companion) =>
      into(playerProfiles).insertOnConflictUpdate(
        companion.copyWith(id: const Value(0)),
      );

  Future<void> setInitialSyncCompleted() =>
      (update(playerProfiles)..where((p) => p.id.equals(0))).write(
        PlayerProfilesCompanion(
          initialSyncCompleted: const Value(true),
          updatedAt: Value(DateTime.now().toUtc().millisecondsSinceEpoch),
        ),
      );
}
