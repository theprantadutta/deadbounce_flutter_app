import 'dart:convert';

import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_event.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_outbox_writer.dart';
import 'package:deadbounce_flutter_app/features/auth/domain/entities/account_link_result.dart';
import 'package:deadbounce_flutter_app/features/auth/domain/entities/auth_user.dart';
import 'package:deadbounce_flutter_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProfileRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ProfileRepositoryImpl(db, SyncOutboxWriter(db));
  });

  tearDown(() => db.close());

  Future<void> seedGuest({String? displayName}) => db.profileDao.upsertProfile(
        PlayerProfilesCompanion(
          userId: const Value('user-1'),
          displayName: Value(displayName),
          isGuest: const Value(true),
          createdAt: const Value(1000),
          updatedAt: const Value(1000),
        ),
      );

  group('markAccountLinked', () {
    test('flips the profile off guest AND queues the sync event', () async {
      await seedGuest();

      await repo.markAccountLinked(
        provider: 'google',
        displayName: 'Pranta',
        photoUrl: 'https://example.test/a.png',
      );

      final profile = await db.profileDao.getProfile();
      expect(profile!.isGuest, isFalse);
      expect(profile.displayName, 'Pranta');
      expect(profile.photoUrl, 'https://example.test/a.png');

      final outbox = await db.select(db.syncOutbox).get();
      expect(outbox, hasLength(1));
      expect(outbox.single.entityType, SyncEntityType.accountLinked.name);

      // The backend's AccountLinkedProcessor parses this field into its
      // AuthProvider enum — if the key or casing drifts, the link silently
      // never flips server-side.
      final payload =
          jsonDecode(outbox.single.payload) as Map<String, dynamic>;
      expect(payload['provider'], 'google');
    });

    test('preserves createdAt (it is an insert-or-update, not a replace)',
        () async {
      await seedGuest();

      await repo.markAccountLinked(provider: 'google');

      expect((await db.profileDao.getProfile())!.createdAt, 1000);
    });

    test('never blanks an existing display name when Google gives none',
        () async {
      await seedGuest(displayName: 'Stranger');

      await repo.markAccountLinked(provider: 'google', displayName: null);

      expect((await db.profileDao.getProfile())!.displayName, 'Stranger');
    });

    test('treats an empty display name the same as none', () async {
      await seedGuest(displayName: 'Stranger');

      await repo.markAccountLinked(provider: 'google', displayName: '');

      expect((await db.profileDao.getProfile())!.displayName, 'Stranger');
    });

    test('getProfile reports the linked account as not-a-guest', () async {
      await seedGuest(displayName: 'Pranta');

      await repo.markAccountLinked(provider: 'google');

      expect((await repo.getProfile()).isGuest, isFalse);
    });
  });

  group('AccountLinkResult', () {
    // The Profile CTA switches exhaustively over these; the sealed hierarchy
    // is what makes a missing branch a compile error rather than a silent
    // no-op on a screen that just took the player's account.
    test('success carries the linked user', () {
      const user = AuthUser(id: 'u1', isAnonymous: false, email: 'a@b.test');
      const result = AccountLinkSuccess(user);

      expect(result.user.isAnonymous, isFalse);
      expect(result.user.email, 'a@b.test');
    });

    test('credential-in-use carries the conflicting email when known', () {
      const result = AccountLinkCredentialInUse(email: 'taken@b.test');
      expect(result.email, 'taken@b.test');
    });

    test('credential-in-use tolerates an unknown email', () {
      const result = AccountLinkCredentialInUse();
      expect(result.email, isNull);
    });

    test('failure carries a presentable message', () {
      const result = AccountLinkFailed('Network error. Check your connection.');
      expect(result.message, isNotEmpty);
    });
  });
}
