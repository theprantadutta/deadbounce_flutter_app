import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Deadbounce's page transition — a "ricochet" shared-axis move: the incoming
/// page eases in from the right with a slight scale + fade while the page
/// underneath parallaxes back and dims. Honors the platform reduce-motion
/// setting (falls back to a clean cross-fade).
///
/// Use via [dbPage] in the router's `pageBuilder`.
CustomTransitionPage<T> dbPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: _buildTransition,
    child: child,
  );
}

Widget _buildTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  // Accessibility: skip the motion, just cross-fade.
  if (MediaQuery.of(context).disableAnimations) {
    return FadeTransition(opacity: animation, child: child);
  }

  // Incoming page.
  final inCurve = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  // This page being covered by a newer one (push) / revealed (pop).
  final underCurve = CurvedAnimation(
    parent: secondaryAnimation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  final slideIn =
      Tween(begin: const Offset(0.18, 0), end: Offset.zero).animate(inCurve);
  final slideUnder =
      Tween(begin: Offset.zero, end: const Offset(-0.08, 0)).animate(underCurve);
  final dimUnder = Tween(begin: 1.0, end: 0.55).animate(underCurve);

  return SlideTransition(
    position: slideUnder,
    child: FadeTransition(
      opacity: dimUnder,
      child: SlideTransition(
        position: slideIn,
        child: FadeTransition(
          opacity: inCurve,
          child: ScaleTransition(
            scale: Tween(begin: 0.97, end: 1.0).animate(inCurve),
            child: child,
          ),
        ),
      ),
    ),
  );
}
