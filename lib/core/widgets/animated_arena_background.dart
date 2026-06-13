import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_effects.dart';

/// The brand's living backdrop: the arena gradient with slow amber/blue
/// embers drifting upward. Reused by the loading screens, home, and the
/// meta screens so the whole app breathes the same air.
class AnimatedArenaBackground extends StatefulWidget {
  const AnimatedArenaBackground({
    super.key,
    this.child,
    this.emberCount = 28,
  });

  final Widget? child;
  final int emberCount;

  @override
  State<AnimatedArenaBackground> createState() =>
      _AnimatedArenaBackgroundState();
}

class _AnimatedArenaBackgroundState extends State<AnimatedArenaBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  late final List<_Ember> _embers = List.generate(
    widget.emberCount,
    (i) => _Ember.seeded(i),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effects = Theme.of(context).extension<AppEffects>()!;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: effects.arenaGradient),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _EmberPainter(_embers, _controller.value),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

class _Ember {
  _Ember({
    required this.x,
    required this.size,
    required this.speed,
    required this.phase,
    required this.amber,
    required this.drift,
  });

  factory _Ember.seeded(int i) {
    final r = math.Random(i * 9973 + 7);
    return _Ember(
      x: r.nextDouble(),
      size: 1.0 + r.nextDouble() * 2.6,
      speed: 0.4 + r.nextDouble() * 0.9,
      phase: r.nextDouble(),
      amber: r.nextDouble() < 0.7,
      drift: (r.nextDouble() - 0.5) * 0.06,
    );
  }

  final double x;
  final double size;
  final double speed;
  final double phase;
  final bool amber;
  final double drift;
}

class _EmberPainter extends CustomPainter {
  _EmberPainter(this.embers, this.t);

  final List<_Ember> embers;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final e in embers) {
      final progress = (t * e.speed + e.phase) % 1.0;
      final y = size.height * (1 - progress);
      final x = size.width * (e.x + e.drift * math.sin(progress * math.pi * 2));
      final flicker = 0.2 + 0.25 * math.sin((progress + e.phase) * math.pi * 6);
      final fade = (progress < 0.1
              ? progress / 0.1
              : progress > 0.85
                  ? (1 - progress) / 0.15
                  : 1.0)
          .clamp(0.0, 1.0);

      final color = (e.amber ? AppColors.amber400 : AppColors.blue400)
          .withValues(alpha: (flicker * fade).clamp(0.0, 0.5));
      canvas.drawCircle(Offset(x, y), e.size, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_EmberPainter old) => old.t != t;
}
