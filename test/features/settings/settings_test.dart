import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/features/game/presentation/game/game_feel.dart';
import 'package:deadbounce_flutter_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:deadbounce_flutter_app/features/settings/domain/entities/app_settings.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParticleQuality', () {
    test('budgets map low/medium/high', () {
      expect(ParticleQuality.low.budget, 250);
      expect(ParticleQuality.medium.budget, 600);
      expect(ParticleQuality.high.budget, 1200);
    });

    test('fromName parses known names and falls back to medium', () {
      expect(ParticleQuality.fromName('high'), ParticleQuality.high);
      expect(ParticleQuality.fromName('low'), ParticleQuality.low);
      expect(ParticleQuality.fromName(null), ParticleQuality.medium);
      expect(ParticleQuality.fromName('bogus'), ParticleQuality.medium);
    });
  });

  group('GameFeel from settings', () {
    test('defaults reproduce shipped behavior', () {
      const feel = GameFeel();
      expect(feel.screenShake, isTrue);
      expect(feel.hitStop, isTrue);
      expect(feel.aimGuide, isTrue);
      expect(feel.combatText, isTrue);
      expect(feel.particleBudget, 600);
    });

    test('maps an AppSettings into the run feel (quality → budget)', () {
      const settings = AppSettings(
        screenShakeEnabled: false,
        hitStopEnabled: false,
        aimGuideEnabled: true,
        combatTextEnabled: false,
        particleQuality: ParticleQuality.high,
      );
      final feel = GameFeel(
        screenShake: settings.screenShakeEnabled,
        hitStop: settings.hitStopEnabled,
        aimGuide: settings.aimGuideEnabled,
        combatText: settings.combatTextEnabled,
        particleBudget: settings.particleQuality.budget,
      );
      expect(feel.screenShake, isFalse);
      expect(feel.hitStop, isFalse);
      expect(feel.aimGuide, isTrue);
      expect(feel.combatText, isFalse);
      expect(feel.particleBudget, 1200);
    });
  });

  group('SettingsRepository round-trip', () {
    late AppDatabase db;
    late SettingsRepositoryImpl repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = SettingsRepositoryImpl(db);
    });
    tearDown(() => db.close());

    test('a fresh store loads all defaults (everything on, medium)', () async {
      final s = await repo.load();
      expect(s.soundEnabled, isTrue);
      expect(s.hapticsEnabled, isTrue);
      expect(s.musicEnabled, isTrue);
      expect(s.screenShakeEnabled, isTrue);
      expect(s.hitStopEnabled, isTrue);
      expect(s.aimGuideEnabled, isTrue);
      expect(s.combatTextEnabled, isTrue);
      expect(s.particleQuality, ParticleQuality.medium);
    });

    test('persists and restores every new field', () async {
      await repo.setScreenShakeEnabled(false);
      await repo.setHitStopEnabled(false);
      await repo.setAimGuideEnabled(false);
      await repo.setCombatTextEnabled(false);
      await repo.setParticleQuality(ParticleQuality.low);

      final s = await repo.load();
      expect(s.screenShakeEnabled, isFalse);
      expect(s.hitStopEnabled, isFalse);
      expect(s.aimGuideEnabled, isFalse);
      expect(s.combatTextEnabled, isFalse);
      expect(s.particleQuality, ParticleQuality.low);
      // Untouched audio settings keep their defaults.
      expect(s.soundEnabled, isTrue);
      expect(s.musicEnabled, isTrue);
    });
  });
}
