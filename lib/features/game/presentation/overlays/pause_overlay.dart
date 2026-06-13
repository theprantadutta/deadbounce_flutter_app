import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/db_button.dart';
import '../../../../core/widgets/db_logo.dart';

/// Blur-dimmed pause menu over the frozen arena.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: DbLogo(size: 56)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'HOLSTERED',
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'The arena waits on you, partner.',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  DbPrimaryButton(
                    label: 'RESUME',
                    icon: Icons.play_arrow_rounded,
                    onPressed: onResume,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DbSecondaryButton(
                    label: 'RESTART RUN',
                    icon: Icons.replay,
                    onPressed: onRestart,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DbSecondaryButton(
                    label: 'QUIT TO MENU',
                    icon: Icons.logout,
                    onPressed: onQuit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
