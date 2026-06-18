import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_effects.dart';

/// The brand's living backdrop, used app-wide (home, meta screens, auth,
/// loading, game overlays) so every screen breathes the same arena air:
/// the arena gradient with a neon perspective floor grid scrolling toward the
/// viewer, a couple of ricochet tracer bullets bouncing off the edges (the
/// core mechanic, alive), drifting enemy silhouettes, rising embers, and a
/// vignette for contrast behind content.
class AnimatedArenaBackground extends StatefulWidget {
  const AnimatedArenaBackground({
    super.key,
    this.child,
    this.emberCount = 26,
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
    duration: const Duration(seconds: 16),
  )..repeat();

  late final List<_Ember> _embers =
      List.generate(widget.emberCount, (i) => _Ember.seeded(i));
  late final List<_Silhouette> _silhouettes =
      List.generate(5, (i) => _Silhouette.seeded(i));
  // Two ricochet bullets with distinct (integer) bounce frequencies so the
  // looping animation is perfectly seamless.
  static const List<_Tracer> _tracers = [
    _Tracer(cyclesX: 3, cyclesY: 2, phaseX: 0.0, phaseY: 0.4, amber: true),
    _Tracer(cyclesX: 2, cyclesY: 3, phaseX: 0.6, phaseY: 0.1, amber: false),
  ];

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
          painter: _BackdropPainter(
            t: _controller.value,
            embers: _embers,
            silhouettes: _silhouettes,
            tracers: _tracers,
          ),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Triangle wave in [0,1] with period 2 — a value bouncing between the edges.
double _tri(double u) {
  final p = u % 2.0;
  return p < 1.0 ? p : 2.0 - p;
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({
    required this.t,
    required this.embers,
    required this.silhouettes,
    required this.tracers,
  });

  final double t;
  final List<_Ember> embers;
  final List<_Silhouette> silhouettes;
  final List<_Tracer> tracers;

  @override
  void paint(Canvas canvas, Size size) {
    _paintFloor(canvas, size);
    _paintSilhouettes(canvas, size);
    _paintEmbers(canvas, size);
    _paintTracers(canvas, size);
    _paintVignette(canvas, size);
  }

  void _paintFloor(Canvas canvas, Size size) {
    final horizon = size.height * 0.62;
    final cx = size.width / 2;
    final floorH = size.height - horizon;

    // Converging verticals from the vanishing point to the bottom edge.
    final vPaint = Paint()
      ..color = AppColors.blue700.withValues(alpha: 0.16)
      ..strokeWidth = 1;
    const cols = 8;
    for (var i = -cols; i <= cols; i++) {
      final bx = cx + (size.width * 0.9) * (i / cols);
      canvas.drawLine(Offset(cx, horizon), Offset(bx, size.height), vPaint);
    }

    // Horizontal lines, denser near the horizon, scrolling toward the viewer.
    const rows = 9;
    for (var i = 0; i < rows; i++) {
      final d = (i / rows + t) % 1.0; // 0 = horizon, 1 = near
      final y = horizon + floorH * d * d;
      final alpha = (0.20 * (1 - d)).clamp(0.0, 0.20);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = AppColors.blue600.withValues(alpha: alpha)
          ..strokeWidth = 1,
      );
    }
  }

  void _paintSilhouettes(Canvas canvas, Size size) {
    for (final s in silhouettes) {
      final prog = (t * s.speed + s.phase) % 1.0;
      final x = size.width * (s.x + s.drift * math.sin(prog * math.pi * 2));
      final y = size.height * (0.15 + 0.45 * s.band);
      canvas.drawCircle(
        Offset(x, y),
        s.radius,
        Paint()..color = AppColors.ink500.withValues(alpha: 0.18),
      );
      canvas.drawCircle(
        Offset(x, y),
        s.radius,
        Paint()
          ..color = AppColors.blue700.withValues(alpha: 0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _paintEmbers(Canvas canvas, Size size) {
    for (final e in embers) {
      final progress = (t * e.speed + e.phase) % 1.0;
      final y = size.height * (1 - progress);
      final x =
          size.width * (e.x + e.drift * math.sin(progress * math.pi * 2));
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

  void _paintTracers(Canvas canvas, Size size) {
    const margin = 0.08;
    double mapX(double v) => size.width * (margin + (1 - 2 * margin) * v);
    double mapY(double v) => size.height * (margin + (1 - 2 * margin) * v);

    for (final tr in tracers) {
      final color = tr.amber ? AppColors.amber400 : AppColors.blue400;
      Offset at(double tt) => Offset(
            mapX(_tri(tt * 2 * tr.cyclesX + tr.phaseX)),
            mapY(_tri(tt * 2 * tr.cyclesY + tr.phaseY)),
          );
      // Fading trail behind the head.
      const samples = 7;
      for (var i = samples; i >= 1; i--) {
        final a = at((t - i * 0.012) % 1.0);
        final b = at((t - (i - 1) * 0.012) % 1.0);
        final alpha = 0.28 * (1 - i / samples);
        canvas.drawLine(
          a,
          b,
          Paint()
            ..color = color.withValues(alpha: alpha)
            ..strokeWidth = 2.4
            ..strokeCap = StrokeCap.round,
        );
      }
      // Glowing head.
      final head = at(t);
      canvas.drawCircle(
          head, 6, Paint()..color = color.withValues(alpha: 0.22));
      canvas.drawCircle(
          head, 2.4, Paint()..color = AppColors.amber100.withValues(alpha: 0.85));
    }
  }

  void _paintVignette(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.1),
        radius: 1.1,
        colors: [
          Colors.transparent,
          AppColors.ink950.withValues(alpha: 0.55),
        ],
        stops: const [0.6, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => old.t != t;
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

class _Silhouette {
  _Silhouette({
    required this.x,
    required this.band,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.drift,
  });

  factory _Silhouette.seeded(int i) {
    final r = math.Random(i * 7717 + 31);
    return _Silhouette(
      x: r.nextDouble(),
      band: r.nextDouble(),
      radius: 10 + r.nextDouble() * 16,
      speed: 0.15 + r.nextDouble() * 0.25,
      phase: r.nextDouble(),
      drift: 0.1 + r.nextDouble() * 0.2,
    );
  }

  final double x;
  final double band;
  final double radius;
  final double speed;
  final double phase;
  final double drift;
}

class _Tracer {
  const _Tracer({
    required this.cyclesX,
    required this.cyclesY,
    required this.phaseX,
    required this.phaseY,
    required this.amber,
  });

  final int cyclesX;
  final int cyclesY;
  final double phaseX;
  final double phaseY;
  final bool amber;
}
