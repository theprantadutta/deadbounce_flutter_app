import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../domain/entities/tournament.dart';
import 'tournament_countdown.dart';

/// A tournament in the list: name, tagline, live countdown, entry fee / reward,
/// and the primary action for its current state (JOIN / PLAY / CLAIM / RESULT).
/// Tapping the body opens the detail + leaderboard.
class TournamentCard extends StatelessWidget {
  const TournamentCard({
    super.key,
    required this.tournament,
    required this.onJoin,
    required this.onPlay,
    required this.onClaim,
    required this.onOpen,
  });

  final Tournament tournament;
  final VoidCallback onJoin;
  final VoidCallback onPlay;
  final VoidCallback onClaim;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: AppRadii.lgAll,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.ink800.withValues(alpha: 0.85),
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: AppColors.amber600),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(tournament.name,
                        style: textTheme.titleSmall, maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (tournament.joined && tournament.isActive)
                    _Tag('JOINED', AppColors.blue300),
                ],
              ),
              const SizedBox(height: 2),
              Text(tournament.tagline,
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(tournament.isEnded ? Icons.flag_outlined : Icons.schedule,
                      size: 14, color: AppColors.ink300),
                  const SizedBox(width: 4),
                  TournamentCountdown(
                    endsAt: tournament.endsAt,
                    style: textTheme.labelSmall,
                  ),
                  const Spacer(),
                  if (tournament.topReward > 0) ...[
                    const Icon(Icons.emoji_events,
                        size: 14, color: AppColors.amber400),
                    const SizedBox(width: 3),
                    Text('${tournament.topReward}', style: textTheme.labelMedium),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(width: double.infinity, child: _action(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _action(BuildContext context) {
    if (tournament.isEnded) {
      if (tournament.hasUnclaimedReward) {
        return _ActionButton(
          label: 'CLAIM ${tournament.rewardCoins}',
          icon: Icons.emoji_events,
          onTap: onClaim,
          filled: true,
        );
      }
      return _ActionButton(
          label: 'VIEW RESULT', icon: Icons.bar_chart, onTap: onOpen);
    }
    if (tournament.joined) {
      return _ActionButton(
          label: 'PLAY', icon: Icons.play_arrow_rounded, onTap: onPlay, filled: true);
    }
    return _ActionButton(
      label: 'JOIN · ${tournament.entryFeeCoins}',
      icon: Icons.login,
      onTap: onJoin,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.onAmber : AppColors.amber300;
    return Material(
      color: filled ? AppColors.amber500 : Colors.transparent,
      borderRadius: AppRadii.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: filled
              ? null
              : BoxDecoration(
                  borderRadius: AppRadii.mdAll,
                  border: Border.all(color: AppColors.amber600),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 6),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: color, fontSize: 9, letterSpacing: 1)),
    );
  }
}
