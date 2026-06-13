import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/animated_arena_background.dart';

/// Shared chrome for the auth screens: the living arena background,
/// centered, width-constrained, scrollable content. Layout is driven by
/// [LayoutBuilder] constraints so it holds up from small phones to
/// tablets without hardcoded pixel layouts.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedArenaBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth > 600 ? AppSpacing.xxl : AppSpacing.lg;

              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: AppSpacing.lg,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: child,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
