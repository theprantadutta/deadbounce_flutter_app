import 'package:firebase_analytics/firebase_analytics.dart';

import '../logging/app_logger.dart';
import 'analytics_service.dart';

/// Firebase-backed [AnalyticsService].
///
/// Every call is wrapped: a telemetry failure logs through Talker (debug-only)
/// and is otherwise invisible. Nothing here may ever throw into a caller —
/// these run on the run-end path.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: (parameters == null || parameters.isEmpty)
            ? null
            : parameters,
      );
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[analytics] logEvent($name) failed');
    }
  }

  @override
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e, st) {
      AppLogger.talker
          .handle(e, st, '[analytics] logScreenView($screenName) failed');
    }
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[analytics] setUserProperty($name) failed');
    }
  }

  @override
  Future<void> setUserId(String? id) async {
    try {
      await _analytics.setUserId(id: id);
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[analytics] setUserId failed');
    }
  }
}
