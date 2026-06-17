import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../domain/entities/home_summary.dart';

/// A compact row of glowing stat chips — BEST score, lifetime KILLS, and
/// all-time RANK — the "numbers going up" hook that pulls players back.
class HomeStatChips extends StatelessWidget {
  const HomeStatChips({super.key, required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Chip(
            label: 'BEST',
            value: _fmtInt(summary.bestScore),
            accent: AppColors.amber400,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _Chip(
            label: 'KILLS',
            value: _fmtInt(summary.totalKills),
            accent: AppColors.blue400,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _Chip(
            label: 'RANK',
            value: summary.rank == null ? '—' : '#${summary.rank}',
            accent: AppColors.blue300,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value, required this.accent});

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.78),
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: accent.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.12), blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: textTheme.titleMedium?.copyWith(color: accent)),
          ),
          const SizedBox(height: 2),
          Text(label, style: textTheme.labelSmall),
        ],
      ),
    );
  }
}

String _fmtInt(int n) {
  final s = n.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
