import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import 'animated_arena_background.dart';
import 'db_screen_header.dart';

/// Shared chrome for the meta screens (leaderboard, awards, profile,
/// settings, daily challenge): the living arena background, a custom
/// fully-transparent header with a back button (no Material `AppBar`, so no
/// surface tint when content scrolls under it), and a width-constrained body.
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
    // Scaffold (kept for ScaffoldMessenger/SnackBars). The frosted header is
    // full-bleed at the top (it owns the status-bar inset so the blur reaches
    // the screen edge), with the body taking the remaining safe area below it.
    // There is no Material `AppBar`, so nothing paints a surface tint on scroll.
    return Stack(
      children: [
        const Positioned.fill(child: AnimatedArenaBackground()),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              DbScreenHeader(title: title, actions: actions, bottom: bottom),
              Expanded(
                child: SafeArea(
                  top: false,
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
          ),
        ),
      ],
    );
  }
}
