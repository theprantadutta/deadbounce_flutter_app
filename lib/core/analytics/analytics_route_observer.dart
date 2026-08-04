import 'package:flutter/widgets.dart';

import 'analytics.dart';

/// Reports a screen view whenever the top-most route changes.
///
/// Reads `RouteSettings.name`, which [dbPage] populates with the GoRouter
/// route **pattern** (`/tournament/:id`) rather than the resolved path — so
/// parameterised routes group into one screen instead of exploding into one
/// screen per id (Firebase caps distinct screen names, and per-id rows are
/// useless anyway).
///
/// Anonymous routes (dialogs, bottom sheets, anything pushed without a name)
/// are skipped rather than reported as "null".
class AnalyticsRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _report(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // The screen being *returned to* is the one now on screen.
    _report(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _report(newRoute);
  }

  void _report(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty) return;
    Analytics.screenView(name);
  }
}
