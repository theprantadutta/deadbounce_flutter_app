import '../logging/app_logger.dart';
import 'analytics_service.dart';

/// Debug-build [AnalyticsService]: prints every event through Talker and
/// uploads **nothing**.
///
/// Why not just point debug builds at Firebase? Because at indie volume a
/// handful of dev sessions visibly skews D1 retention and funnel rates — the
/// exact numbers this whole phase exists to measure. So debug gets full
/// visibility (Settings → Diagnostics → View logs shows every event as you
/// trigger it) with zero production pollution.
class LoggingAnalyticsService implements AnalyticsService {
  const LoggingAnalyticsService();

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    AppLogger.talker.info(
      '[analytics] $name${parameters == null || parameters.isEmpty ? '' : ' $parameters'}',
    );
  }

  @override
  Future<void> logScreenView(String screenName) async {
    AppLogger.talker.info('[analytics] screen_view $screenName');
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    AppLogger.talker.info('[analytics] property $name=$value');
  }

  @override
  Future<void> setUserId(String? id) async {
    AppLogger.talker.info('[analytics] user_id=${id ?? '(cleared)'}');
  }
}
