import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The marquee call-to-action as a glowing bullet/orb you tap to launch into
/// the arena. A spherical amber gradient with a target ring, a breathing
/// amber+blue neon aura, and a press-down spring. Built for the home screen's
/// single most important action.
class DbLaunchButton extends StatefulWidget {
  const DbLaunchButton({
    super.key,
    required this.onPressed,
    this.label = 'LAUNCH',
    this.diameter = 184,
  });

  final VoidCallback? onPressed;
  final String label;
  final double diameter;

  @override
  State<DbLaunchButton> createState() => _DbLaunchButtonState();
}

class _DbLaunchButtonState extends State<DbLaunchButton>
    with SingleTickerProviderStateMixin {
  // The breathing halo.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    if (widget.onPressed != null) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(DbLaunchButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final enabled = widget.onPressed != null;
    if (enabled && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!enabled && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final enabled = widget.onPressed != null;
    final d = widget.diameter;

    return AnimatedScale(
      scale: _pressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final t = enabled ? Curves.easeInOut.transform(_pulse.value) : 0.0;
          return Container(
            width: d,
            height: d,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: enabled
                  ? [
                      // Amber core glow.
                      BoxShadow(
                        color: AppColors.amber500
                            .withValues(alpha: 0.40 + 0.25 * t),
                        blurRadius: 26 + 22 * t,
                        spreadRadius: 2 + 5 * t,
                      ),
                      // Electric-blue outer wash — the aura.
                      BoxShadow(
                        color: AppColors.blue500
                            .withValues(alpha: 0.12 + 0.12 * t),
                        blurRadius: 44 + 28 * t,
                        spreadRadius: 4 + 6 * t,
                      ),
                    ]
                  : null,
            ),
            child: child,
          );
        },
        child: ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              customBorder: const CircleBorder(),
              onHighlightChanged: (v) => setState(() => _pressed = v),
              splashColor: Colors.white.withValues(alpha: 0.18),
              highlightColor: Colors.white.withValues(alpha: 0.06),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Off-centre focal point fakes a lit sphere (bullet/ball).
                  gradient: enabled
                      ? const RadialGradient(
                          center: Alignment(-0.35, -0.45),
                          radius: 1.05,
                          colors: [
                            AppColors.amber200,
                            AppColors.amber400,
                            AppColors.amber500,
                            AppColors.amber700,
                          ],
                          stops: [0.0, 0.38, 0.66, 1.0],
                        )
                      : const RadialGradient(
                          colors: [AppColors.ink700, AppColors.ink800],
                        ),
                  border: Border.all(
                    color: enabled
                        ? AppColors.amber300.withValues(alpha: 0.85)
                        : AppColors.outlineFaint,
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Inner target/casing ring for the bullet feel.
                    Container(
                      margin: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(
                              alpha: enabled ? 0.18 : 0.06),
                          width: 1.4,
                        ),
                      ),
                    ),
                    // Centre label.
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.rocket_launch,
                          size: 25,
                          color:
                              enabled ? AppColors.ink950 : AppColors.ink400,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.label,
                          style: textTheme.titleMedium?.copyWith(
                            color:
                                enabled ? AppColors.ink950 : AppColors.ink400,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
