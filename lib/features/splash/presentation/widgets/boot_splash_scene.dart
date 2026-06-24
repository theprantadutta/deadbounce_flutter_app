import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/animated_arena_background.dart';
import '../../../../core/widgets/db_logo.dart';
import '../../../home/presentation/widgets/hero_orb_rig.dart';
import '../../../home/presentation/widgets/neon_wordmark.dart';

/// The app's first screen — a cinematic boot loader.
///
/// Composes the brand language into a hero lockup: the [DbLogo] inside the
/// living [HeroOrbRig] (rotating ricochet ring + orbiting spark), the
/// shimmering [NeonWordmark], the "no damage till it bounces" tagline, a neon
/// progress sweep, and a rotating "intel card" — the core rules, gunslinger
/// tips, and enemy intel — all over the shared animated arena background, with
/// a staggered entrance. Distinct from the leaner pre-game [DbLoadingScene];
/// this is the one that has to make a first impression.
class BootSplashScene extends StatefulWidget {
  const BootSplashScene({super.key, this.subtitle});

  /// Status line under the wordmark (e.g. "Restoring your gunslinger…").
  /// When null, a quiet default "loading the arena" line is shown.
  final String? subtitle;

  @override
  State<BootSplashScene> createState() => _BootSplashSceneState();
}

class _BootSplashSceneState extends State<BootSplashScene> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (_intel.length > 1) {
      _timer = Timer.periodic(const Duration(milliseconds: 3200), (_) {
        if (mounted) setState(() => _index = (_index + 1) % _intel.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = widget.subtitle;

    return Scaffold(
      body: AnimatedArenaBackground(
        emberCount: 34,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: [
                const Spacer(flex: 5),

                // --- Hero lockup: orb rig + logo, wordmark, tagline ---
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HeroOrbRig(
                      diameter: 132,
                      child: const DbLogo(size: 132)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scaleXY(
                            begin: 0.97,
                            end: 1.05,
                            duration: 1500.ms,
                            curve: Curves.easeInOut,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    NeonWordmark(style: textTheme.displayMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'NO DAMAGE TILL IT BOUNCES',
                      textAlign: TextAlign.center,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.blue300,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                    .scaleXY(
                      begin: 0.86,
                      end: 1,
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                    ),

                const Spacer(flex: 4),

                // --- Status line (reserved height so nothing reflows) ---
                SizedBox(
                  height: 22,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      subtitle ?? 'Loading the arena…',
                      key: ValueKey(subtitle ?? '_default'),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: subtitle != null
                            ? AppColors.blue300
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const _NeonProgressBar(),
                const SizedBox(height: AppSpacing.lg),

                // --- Rotating intel card (rules / tips / enemy intel) ---
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 96),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, 0.12),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: _IntelCard(
                          key: ValueKey(_index),
                          intel: _intel[_index],
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A single rotating piece of loading-screen content.
class _Intel {
  const _Intel(this.kind, this.icon, this.text, {this.accent = _amber});

  final String kind; // small category label: RULE / TIP / INTEL
  final IconData icon;
  final String text;
  final Color accent;

  static const Color _amber = AppColors.amber300;
  static const Color _blue = AppColors.blue300;
}

/// Core rules, gunslinger tips, and enemy intel — the stuff worth reading
/// while the arena boots. Amber = how you play, blue = who you're up against.
const List<_Intel> _intel = [
  _Intel(
    'THE GOLDEN RULE',
    Icons.bolt,
    'Direct hits do ZERO damage. Your bullet only turns lethal after it '
        'ricochets off a wall.',
  ),
  _Intel(
    'TIP',
    Icons.auto_graph,
    'Every bounce adds +1 damage and +12% speed. The deeper the bank, the '
        'harder it lands.',
  ),
  _Intel(
    'TIP',
    Icons.timeline,
    'Line enemies up behind a wall, then bank one shot clean through the '
        'whole row.',
  ),
  _Intel(
    'TIP',
    Icons.local_fire_department,
    'Bullets keep living after a kill — chain them through a crowd before '
        'they expire.',
  ),
  _Intel(
    'TIP',
    Icons.swipe,
    'Tap to dash between three anchors. Movement is for dodging — aiming is '
        'how you win.',
  ),
  _Intel(
    'TIP',
    Icons.auto_awesome,
    'Clear a wave, then pick 1 of 3 upgrade cards. They stack and combine — '
        'build your loadout.',
  ),
  _Intel(
    'INTEL',
    Icons.shield,
    'Wardens block anything under 3 bounces. Bank deep to shatter their '
        'guard.',
    accent: _Intel._blue,
  ),
  _Intel(
    'INTEL',
    Icons.gps_fixed,
    'Turrets dampen the wall they hold — no bounce there until you take them '
        'down.',
    accent: _Intel._blue,
  ),
  _Intel(
    'INTEL',
    Icons.flash_on,
    'Chargers telegraph before they dash. That wind-up is your dodge window.',
    accent: _Intel._blue,
  ),
  _Intel(
    'INTEL',
    Icons.call_split,
    'Splitters break into two drifters on death. Mind the swarm.',
    accent: _Intel._blue,
  ),
  _Intel(
    'INTEL',
    Icons.dangerous,
    'Powderkegs drop a delayed shockwave when they die. Never camp the kill.',
    accent: _Intel._blue,
  ),
  _Intel(
    'INTEL',
    Icons.healing,
    'Sawbones heal nearby enemies. Put them down first.',
    accent: _Intel._blue,
  ),
  _Intel(
    'INTEL',
    Icons.security,
    'Ironhides only crack from the side or back — bank around their frontal '
        'armor.',
    accent: _Intel._blue,
  ),
  _Intel(
    'INTEL',
    Icons.flip,
    'Mirrors give you a free bounce off their front — but only their back '
        'face can be killed.',
    accent: _Intel._blue,
  ),
  _Intel(
    'TIP',
    Icons.favorite,
    'Three hearts, with brief mercy after a hit. Zero hearts ends the run.',
  ),
  _Intel(
    'TIP',
    Icons.handyman,
    'Spend coins at the Gunsmith for permanent perks that ride into every '
        'run.',
  ),
];

/// The styled card that presents one [_Intel] entry — icon badge + category
/// label + text, mirroring the home / how-to-play card language.
class _IntelCard extends StatelessWidget {
  const _IntelCard({super.key, required this.intel});

  final _Intel intel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = intel.accent;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.72),
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: AppRadii.mdAll,
              border: Border.all(color: accent.withValues(alpha: 0.45)),
            ),
            child: Icon(intel.icon, color: accent, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  intel.kind,
                  style: textTheme.labelSmall?.copyWith(
                    color: accent,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  intel.text,
                  style: textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// An indeterminate neon sweep — an amber→blue comet sliding across a dark
/// track, matching the brand gradient.
class _NeonProgressBar extends StatefulWidget {
  const _NeonProgressBar();

  @override
  State<_NeonProgressBar> createState() => _NeonProgressBarState();
}

class _NeonProgressBarState extends State<_NeonProgressBar>
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
                      widthFactor: 0.42,
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
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.amber400.withValues(alpha: 0.35),
                              blurRadius: 10,
                            ),
                          ],
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
