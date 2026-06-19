import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/util/open_external_link.dart';
import '../../../core/widgets/db_logo.dart';
import '../../../core/widgets/meta_scaffold.dart';

/// Who made Deadbounce, with a tappable link out to the author's site.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  static const String _authorName = 'Pranta Dutta';
  static const String _websiteLabel = 'pranta.dev';
  static const String _websiteUrl = 'https://pranta.dev';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MetaScaffold(
      title: 'CREDITS',
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          const SizedBox(height: AppSpacing.sm),
          const Center(child: DbLogo(size: 72)),
          const SizedBox(height: AppSpacing.md),
          Text('DEADBOUNCE',
              style: textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text('A one-thumb neon-western ricochet arena.',
              style: textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),

          // Author.
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.ink800.withValues(alpha: 0.85),
              borderRadius: AppRadii.lgAll,
              border: Border.all(color: AppColors.amber600),
            ),
            child: Column(
              children: [
                Text('DESIGNED & BUILT BY',
                    style: textTheme.labelSmall, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xs),
                Text(_authorName,
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                _WebsiteButton(
                  label: _websiteLabel,
                  url: _websiteUrl,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Tech credits.
          Text('BUILT WITH', style: textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          const _CreditRow(label: 'Flutter', detail: 'UI & app framework'),
          const _CreditRow(label: 'Flame', detail: 'Game engine'),
          const _CreditRow(label: 'Drift', detail: 'Offline-first local data'),
          const _CreditRow(
              label: 'Material Symbols', detail: 'Iconography'),
          const SizedBox(height: AppSpacing.lg),

          Center(
            child: Text('Made with grit in the dust.',
                style: textTheme.bodySmall, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _WebsiteButton extends StatelessWidget {
  const _WebsiteButton({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => openExternalLink(context, url),
        borderRadius: AppRadii.pillAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.ink700,
            borderRadius: AppRadii.pillAll,
            border: Border.all(color: AppColors.blue600),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.public, size: 18, color: AppColors.blue300),
              const SizedBox(width: AppSpacing.xs),
              Text(label,
                  style: textTheme.titleSmall
                      ?.copyWith(color: AppColors.blue300)),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.open_in_new, size: 14, color: AppColors.ink300),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({required this.label, required this.detail});

  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.ink800.withValues(alpha: 0.8),
          borderRadius: AppRadii.mdAll,
          border: Border.all(color: AppColors.outlineFaint),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: textTheme.titleSmall)),
            Text(detail, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
