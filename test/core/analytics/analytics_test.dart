import 'package:deadbounce_flutter_app/core/analytics/analytics.dart';
import 'package:deadbounce_flutter_app/core/analytics/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records everything instead of uploading it.
class _RecordingAnalyticsService implements AnalyticsService {
  final events = <(String, Map<String, Object>?)>[];
  final screens = <String>[];
  final properties = <String, String?>{};
  String? userId;
  bool userIdWasSet = false;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    events.add((name, parameters));
  }

  @override
  Future<void> logScreenView(String screenName) async => screens.add(screenName);

  @override
  Future<void> setUserProperty(String name, String? value) async =>
      properties[name] = value;

  @override
  Future<void> setUserId(String? id) async {
    userId = id;
    userIdWasSet = true;
  }
}

void main() {
  late _RecordingAnalyticsService recorder;

  setUp(() {
    recorder = _RecordingAnalyticsService();
    Analytics.configure(recorder);
  });

  tearDown(Analytics.reset);

  group('Analytics default backend', () {
    test('is a no-op until configured, and after reset', () async {
      Analytics.reset();
      expect(Analytics.service, isA<NoopAnalyticsService>());
      // The whole point: an uninstrumented test must not throw.
      await Analytics.runStart(mode: 'normal', arenaId: 'twin_posts');
    });
  });

  group('event taxonomy', () {
    test('runStart sends mode and arena', () async {
      await Analytics.runStart(mode: 'normal', arenaId: 'twin_posts');

      expect(recorder.events, hasLength(1));
      final (name, params) = recorder.events.single;
      expect(name, 'run_start');
      expect(params, {'mode': 'normal', 'arena_id': 'twin_posts'});
    });

    test('runEnd drops a null causeOfDeath rather than sending null', () async {
      await Analytics.runEnd(
        mode: 'daily',
        wave: 12,
        score: 4200,
        kills: 87,
        durationSeconds: 305,
        coinsEarned: 460,
      );

      final (name, params) = recorder.events.single;
      expect(name, 'run_end');
      expect(params!.containsKey('cause_of_death'), isFalse);
      expect(params['wave'], 12);
      expect(params['mode'], 'daily');
    });

    test('runEnd keeps causeOfDeath when present', () async {
      await Analytics.runEnd(
        mode: 'normal',
        wave: 3,
        score: 100,
        kills: 9,
        durationSeconds: 40,
        coinsEarned: 55,
        causeOfDeath: 'charger',
      );

      expect(recorder.events.single.$2!['cause_of_death'], 'charger');
    });

    test('shopPurchase omits a null level (cosmetics have no levels)', () async {
      await Analytics.shopPurchase(
        shop: 'outfitter',
        itemId: 'trail_ember',
        cost: 300,
      );

      final params = recorder.events.single.$2!;
      expect(params.containsKey('level'), isFalse);
      expect(params['shop'], 'outfitter');
      expect(params['cost'], 300);
    });

    test('continue triple reports the unaffordable case too', () async {
      await Analytics.continueOffered(wave: 7, cost: 500, canAfford: false);

      final params = recorder.events.single.$2!;
      expect(params['can_afford'], false);
    });
  });

  group('Firebase limits are enforced before sending', () {
    test('over-long string values are clamped to 100 chars', () async {
      await Analytics.upgradePicked(
        cardId: 'x' * 250,
        rarity: 'epic',
        wave: 4,
      );

      final cardId = recorder.events.single.$2!['card_id'] as String;
      expect(cardId.length, 100);
    });

    test('numeric values are passed through untouched', () async {
      await Analytics.draftReroll(cost: 60, rerollIndex: 1, wave: 5);

      final params = recorder.events.single.$2!;
      expect(params['cost'], 60);
      expect(params['reroll_index'], 1);
    });
  });

  group('identity', () {
    test('identify forwards the backend user id', () async {
      await Analytics.identify('user-123');
      expect(recorder.userId, 'user-123');
    });

    test('identify(null) clears it on sign-out', () async {
      await Analytics.identify(null);
      expect(recorder.userIdWasSet, isTrue);
      expect(recorder.userId, isNull);
    });

    test('setPlayerProperties only sends the fields provided', () async {
      await Analytics.setPlayerProperties(bestWave: 21);

      expect(recorder.properties, {'best_wave': '21'});
    });

    test('isGuest is sent as a string boolean', () async {
      await Analytics.setPlayerProperties(isGuest: true);

      expect(recorder.properties['is_guest'], 'true');
    });
  });

  group('screen views', () {
    test('go through the dedicated screen API, not logEvent', () async {
      await Analytics.screenView('/gunsmith');

      expect(recorder.screens, ['/gunsmith']);
      expect(recorder.events, isEmpty);
    });
  });
}
