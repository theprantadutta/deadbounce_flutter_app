import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_effects.dart';

/// Shared chrome for the auth screens: deep arena-gradient background,
/// centered, width-constrained, scrollable content. Layout is driven by
/// [LayoutBuilder] constraints so it holds up from small phones to
/// tablets without hardcoded pixel layouts.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final effects = Theme.of(context).extension<AppEffects>()!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: effects.arenaGradient),
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
