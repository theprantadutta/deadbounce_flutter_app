import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_effects.dart';

/// Primary glowing action button. Wraps [FilledButton] with the amber neon
/// halo and a built-in loading state so screens never roll their own.
class DbPrimaryButton extends StatelessWidget {
  const DbPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final effects = Theme.of(context).extension<AppEffects>()!;
    final enabled = onPressed != null && !loading;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadii.mdAll,
        boxShadow: enabled ? effects.amberGlow : null,
      ),
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

/// Secondary (outlined, electric-blue) button for alternate auth providers
/// and less prominent actions.
class DbSecondaryButton extends StatelessWidget {
  const DbSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(label),
              ],
            ),
    );
  }
}
