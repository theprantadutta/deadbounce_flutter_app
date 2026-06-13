import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import 'animated_arena_background.dart';

/// Shared chrome for the meta screens (leaderboard, awards, profile,
/// settings, daily challenge): the living arena background, a transparent
/// app bar with a back button, and a width-constrained body.
class MetaScaffold extends StatelessWidget {
  const MetaScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.bottom,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    // The animated background fills the whole screen behind a transparent
    // Scaffold. The Scaffold body is NOT extended behind the app bar, so
    // content sits directly under the app bar (and tab bar, if any) with
    // no manual top padding — the background still shows through because
    // both the Scaffold and the app bar are transparent.
    return Stack(
      children: [
        const Positioned.fill(child: AnimatedArenaBackground()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(title),
            actions: actions,
            bottom: bottom,
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
