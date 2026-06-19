import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'animated_arena_background.dart';
import 'db_logo.dart';
import 'fitted_headline.dart';

/// A full-screen loading scene: pulsing logo lockup, a styled progress
/// bar, and rotating gameplay tips over the animated arena background.
/// Used by both the boot screen and the pre-game screen, with different
/// copy/flavor.
class DbLoadingScene extends StatefulWidget {
  const DbLoadingScene({
    super.key,
    required this.title,
    required this.tips,
    this.subtitle,
    this.showLogo = true,
  });

  final String title;
  final String? subtitle;
  final List<String> tips;
  final bool showLogo;

  @override
  State<DbLoadingScene> createState() => _DbLoadingSceneState();
}

class _DbLoadingSceneState extends State<DbLoadingScene>
    with TickerProviderStateMixin {
  // Created eagerly in initState (only when shown) — never lazily, so the
  // ticker is born while the element is active. A `late final` initializer
  // would run on first access, which for a logo-less scene is dispose() —
  // creating an AnimationController on a deactivated widget and crashing.
  AnimationController? _pulse;

  Timer? _tipTimer;
  int _tipIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.showLogo) {
      _pulse = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat(reverse: true);
    }
    if (widget.tips.length > 1) {
      _tipTimer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
        if (mounted) {
          setState(() => _tipIndex = (_tipIndex + 1) % widget.tips.length);
        }
      });
    }
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AnimatedArenaBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const Spacer(flex: 3),
                if (widget.showLogo && _pulse != null)
                  ScaleTransition(
                    scale: Tween(begin: 0.94, end: 1.06).animate(
                      CurvedAnimation(parent: _pulse!, curve: Curves.easeInOut),
                    ),
                    child: const DbLogo(size: 104),
                  ),
                const SizedBox(height: AppSpacing.lg),
                FittedHeadline(widget.title, style: textTheme.displaySmall),
                const SizedBox(height: AppSpacing.xs),
                // Always reserve the subtitle line so a status message (e.g.
                // "Restoring your gunslinger…") can fade in without reflowing
                // the rest of the scene.
                SizedBox(
                  height: 24,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: widget.subtitle == null
                        ? const SizedBox.shrink()
                        : Text(
                            widget.subtitle!,
                            key: ValueKey(widget.subtitle),
                            style: textTheme.bodyMedium
                                ?.copyWith(color: AppColors.blue300),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ),
                const Spacer(flex: 2),
                const _IndeterminateBar(),
                const SizedBox(height: AppSpacing.lg),
                // Reserve space to stop layout jumping between tips, but
                // allow growth so a long tip wrapping on a narrow screen
                // never overflows.
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      widget.tips.isEmpty ? '' : widget.tips[_tipIndex],
                      key: ValueKey(_tipIndex),
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndeterminateBar extends StatefulWidget {
  const _IndeterminateBar();

  @override
  State<_IndeterminateBar> createState() => _IndeterminateBarState();
}

class _IndeterminateBarState extends State<_IndeterminateBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: ClipRRect(
        borderRadius: AppRadii.pillAll,
        child: SizedBox(
          height: 6,
          child: Stack(
            children: [
              const ColoredBox(
                color: AppColors.ink700,
                child: SizedBox.expand(),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Align(
                    alignment: Alignment(_controller.value * 2 - 1, 0),
                    child: FractionallySizedBox(
                      widthFactor: 0.4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0x00FFB718),
                              AppColors.amber400,
                              AppColors.blue400,
                              Color(0x0015C1F3),
                            ],
                          ),
                          borderRadius: AppRadii.pillAll,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
