import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Wraps the launch orb with a living "gunslinger core" rig — a slowly
/// rotating dashed ricochet ring, an orbiting spark, and a sweeping aim tick —
/// so the primary CTA reads as the heart of the arena, not just a button.
class HeroOrbRig extends StatefulWidget {
  const HeroOrbRig({super.key, required this.child, required this.diameter});

  /// The orb (e.g. DbLaunchButton) placed at the center.
  final Widget child;

  /// Diameter of the inner orb; the rig adds room around it for the ring.
  final double diameter;

  @override
  State<HeroOrbRig> createState() => _HeroOrbRigState();
}

class _HeroOrbRigState extends State<HeroOrbRig>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final footprint = widget.diameter * 1.42;
    return SizedBox(
      width: footprint,
      height: footprint,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _RigPainter(
                  t: _controller.value,
                  orbRadius: widget.diameter / 2,
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _RigPainter extends CustomPainter {
  _RigPainter({required this.t, required this.orbRadius});

  final double t;
  final double orbRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final ringR = orbRadius * 1.14;
    final spin = t * 2 * math.pi;

    // Dashed ricochet ring, slowly rotating.
    const dashes = 32;
    final ringPaint = Paint()
      ..color = AppColors.blue400.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < dashes; i++) {
      if (i.isOdd) continue; // gaps
      final a0 = spin + (i / dashes) * 2 * math.pi;
      final a1 = a0 + (2 * math.pi / dashes) * 0.6;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ringR),
        a0,
        a1 - a0,
        false,
        ringPaint,
      );
    }

    // Orbiting amber spark on the ring.
    final sparkAngle = -spin * 1.6;
    final spark = center +
        Offset(math.cos(sparkAngle), math.sin(sparkAngle)) * ringR;
    canvas.drawCircle(
        spark, 6, Paint()..color = AppColors.amber400.withValues(alpha: 0.3));
    canvas.drawCircle(
        spark, 2.6, Paint()..color = AppColors.amber200);

    // Sweeping aim tick just outside the orb.
    final aimAngle = spin * 0.8;
    final p1 =
        center + Offset(math.cos(aimAngle), math.sin(aimAngle)) * (orbRadius * 1.02);
    final p2 =
        center + Offset(math.cos(aimAngle), math.sin(aimAngle)) * (ringR * 0.97);
    canvas.drawLine(
      p1,
      p2,
      Paint()
        ..color = AppColors.amber300.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RigPainter old) => old.t != t;
}
