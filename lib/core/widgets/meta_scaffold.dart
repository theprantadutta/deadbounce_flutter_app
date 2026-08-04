import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../ads/ad_banner.dart';
import '../ads/ad_service.dart';

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
    this.showBanner = false,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  /// Opt IN to the meta-screen banner. Off by default on purpose: a banner
  /// that appeared on every MetaScaffold would land on the Gunsmith, the
  /// Outfitter and the store — asking a player to look at an ad on the screen
  /// where they're about to spend money. Only the four read-only screens
  /// (Leaderboards, Awards, Statistics, Trick-Shot gallery) pass true.
  final bool showBanner;

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
              // Anchored at the bottom, below the safe area, and renders
              // nothing at all until an ad actually loads — so a screen with
              // no fill looks exactly as it did before ads existed.
              if (showBanner)
                SafeArea(
                  top: false,
                  child: AdBanner(adService: context.read<AdService>()),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
