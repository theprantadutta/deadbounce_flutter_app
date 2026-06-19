import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A fully transparent screen header for the internal/meta screens — a
/// neon-western replacement for Material's `AppBar`. It paints **nothing**
/// behind the title/back button, so the living arena background (grid, embers,
/// ricochet bullets) stays fully visible through it, and unlike an `AppBar` it
/// never shows a surface tint when content scrolls beneath it.
///
/// It is full-bleed to the top edge (it absorbs the status-bar inset) and hosts
/// the optional [bottom] strip (e.g. the Leaderboards tab bar). The title is
/// centered via a [Stack] so it holds regardless of [actions].
class DbScreenHeader extends StatelessWidget {
  const DbScreenHeader({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final topInset = MediaQuery.paddingOf(context).top;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: topInset),
        SizedBox(
          height: kToolbarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 56),
                child: Text(
                  title,
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _GlassIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.of(context).maybePop(),
                    semanticLabel: 'Back',
                  ),
                ),
              ),
              if (actions != null && actions!.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ?bottom,
      ],
    );
  }
}

/// A ~40px circular translucent icon button matching the home nav glass tiles.
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ink800.withValues(alpha: 0.6),
            border: Border.all(color: AppColors.outlineFaint),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: AppColors.textPrimary,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}
