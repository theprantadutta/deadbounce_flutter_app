import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../game/hud_model.dart';

/// The combo meter: a neon chip showing the live chain length with a
/// draining radial ring (the ~1.4s chain window closing). Pops on each
/// increment. Hidden unless an actual chain (>= 2) is live — chains are
/// the whole identity of the game, so this is the HUD's hero element.
class ChainMeter extends StatelessWidget {
  const ChainMeter({super.key, required this.hud});

  final HudModel hud;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: hud.chainLength,
      builder: (context, length, _) {
        if (length < 2) return const SizedBox(height: 64);
        return ValueListenableBuilder<double>(
          valueListenable: hud.chainRemaining,
          builder: (context, remaining, _) {
            return _ChainChip(length: length, remaining: remaining)
                // Replay a punchy pop each time the chain grows.
                .animate(key: ValueKey(length))
                .scaleXY(
                  begin: 1.35,
                  end: 1,
                  duration: 220.ms,
                  curve: Curves.easeOutBack,
                );
          },
        );
      },
    );
  }
}

class _ChainChip extends StatelessWidget {
  const _ChainChip({required this.length, required this.remaining});

  final int length;
  final double remaining;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Hotter color as the chain climbs.
    final color = switch (length) {
      2 => AppColors.blue300,
      3 => AppColors.amber300,
      4 => AppColors.amber400,
      _ => AppColors.error,
    };

    return SizedBox(
      height: 64,
      child: Center(
        child: CustomPaint(
          painter: _RingPainter(remaining: remaining, color: color),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  'CHAIN',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.ink100,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '×$length',
                  style: textTheme.titleMedium?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill background + a draining arc tracing the top edge as the chain
/// window closes.
class _RingPainter extends CustomPainter {
  _RingPainter({required this.remaining, required this.color});

  final double remaining;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(999));

    // Glassy fill + faint outline.
    canvas.drawRRect(
      rrect,
      Paint()..color = const Color(0xCC0E101B),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.ink500.withValues(alpha: 0.4),
    );

    // Draining progress arc along the pill border.
    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = color;
    final path = Path()..addRRect(rrect.deflate(1.5));
    final metric = path.computeMetrics().first;
    final len = metric.length * remaining.clamp(0.0, 1.0);
    if (len > 0) {
      canvas.drawPath(metric.extractPath(0, len), progress);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.remaining != remaining || old.color != color;
}
