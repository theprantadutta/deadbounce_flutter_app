import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/meta_scaffold.dart';

/// Static rulebook in the Deadbounce voice: the bounce rule, controls,
/// enemies, and upgrades.
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MetaScaffold(
      title: 'HOW TO PLAY',
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: const [
          _GoldenRule(),
          SizedBox(height: AppSpacing.lg),
          _Step(
            icon: Icons.my_location,
            title: 'AIM',
            body: 'Drag anywhere to aim — it slingshots from where your thumb '
                'lands, so your hand never covers the arena. A live line shows '
                'exactly where your shot will ricochet. Longer drag = more power.',
          ),
          _Step(
            icon: Icons.sports_esports,
            title: 'FIRE',
            body: 'Release past the deadzone to shoot. Your bullet keeps living '
                'after a kill — chain it through a crowd before it expires.',
          ),
          _Step(
            icon: Icons.swipe,
            title: 'DASH',
            body: 'A quick tap (or a tiny drag) dashes you to the nearest of '
                'three positions along the bottom. Aiming is the skill — '
                'movement is just for dodging.',
          ),
          _Step(
            icon: Icons.favorite,
            title: 'STAY ALIVE',
            body: 'You start with 3 hearts. Touching an enemy costs a heart and '
                'grants a short window of invulnerability. Zero hearts ends '
                'the run.',
          ),
          _Step(
            icon: Icons.auto_awesome,
            title: 'UPGRADE',
            body: 'Clear a wave and pick 1 of 3 cards. They stack and combine — '
                'split shots, incendiary trails, rubber walls, ghost rounds and '
                'more. Build a loadout that fits your aim.',
          ),
          SizedBox(height: AppSpacing.lg),
          _EnemyList(),
          SizedBox(height: AppSpacing.lg),
          _Tips(),
        ],
      ),
    );
  }
}

class _GoldenRule extends StatelessWidget {
  const _GoldenRule();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.amber500.withValues(alpha: 0.12),
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.amber500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.amber400, size: 22),
              const SizedBox(width: AppSpacing.xs),
              Text('THE GOLDEN RULE',
                  style: textTheme.titleSmall
                      ?.copyWith(color: AppColors.amber300)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your bullets do ZERO damage on a direct hit. They only turn lethal '
            'after ricocheting off a wall — each bounce adds +1 damage and '
            '+12% speed. Bank your shots off the walls to deal the hurt.',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.ink800.withValues(alpha: 0.8),
          borderRadius: AppRadii.lgAll,
          border: Border.all(color: AppColors.outlineFaint),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.ink700,
                borderRadius: AppRadii.mdAll,
              ),
              child: Icon(icon, color: AppColors.amber300, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(body, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnemyList extends StatelessWidget {
  const _EnemyList();

  static const List<(IconData, String, String)> _enemies = [
    (Icons.blur_on, 'Drifter', 'Slow floater. Easy pickings — one bounce ends it.'),
    (Icons.bolt, 'Charger', 'Winds up, then dashes in a straight line. The '
        'telegraph is your dodge window.'),
    (Icons.call_split, 'Splitter', 'Splits into two small drifters when it '
        'dies. Mind the swarm.'),
    (Icons.gps_fixed, 'Turret', 'Claims a wall and kills its bounce while it '
        'lives. Shoot it down to free the wall.'),
    (Icons.shield, 'Warden', 'Mini-boss. Its shield blocks anything under 3 '
        'bounces — bank deep to break it.'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KNOW YOUR ENEMY', style: textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.ink800.withValues(alpha: 0.8),
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: AppColors.outlineFaint),
          ),
          child: Column(
            children: [
              for (final (icon, name, desc) in _enemies)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 18, color: AppColors.blue300),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: textTheme.titleSmall),
                            Text(desc, style: textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips();

  static const List<String> _tips = [
    'Line enemies up behind a wall, then bank a shot through all of them.',
    'A bullet that has bounced a lot hits harder AND moves faster — respect it.',
    'Wardens fear the third bounce. So does everything tough.',
    'Dash to reset your angle, not to run — the arena is small on purpose.',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GUNSLINGER TIPS', style: textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final tip in _tips)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.chevron_right,
                    color: AppColors.amber400, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(tip, style: textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}
