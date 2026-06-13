import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../engine/trajectory/trajectory_predictor.dart';
import '../../../engine/tuning.dart';

/// The premium aim line: dashed segments with an animated flow phase,
/// color shifting per predicted bounce (dim → amber → blue → white-hot),
/// rings at bounce points, gray markers on dampened sections. Dim while
/// the drag is under the cancel threshold.
class TrajectoryComponent extends Component {
  List<TrajectoryNode> nodes = const [];
  bool visible = false;
  bool dimmed = false;

  double _dashPhase = 0;

  static const List<Color> _legColors = [
    AppColors.ink200, // leg 0 — pre-bounce, harmless
    AppColors.amber400, // after bounce 1
    AppColors.blue400, // after bounce 2
    Color(0xFFFFFFFF), // after bounce 3+ — white-hot
  ];

  @override
  void update(double dt) {
    _dashPhase += dt * Tuning.trajectory.flowSpeed;
  }

  @override
  void render(Canvas canvas) {
    if (!visible || nodes.length < 2) return;
    const t = Tuning.trajectory;
    final alpha = dimmed ? 0.25 : 0.9;

    for (var i = 1; i < nodes.length; i++) {
      final from = nodes[i - 1].point;
      final to = nodes[i].point;
      final legIndex =
          nodes[i - 1].bounceIndex.clamp(0, _legColors.length - 1);
      final color = nodes[i].dampened
          ? AppColors.ink300
          : _legColors[legIndex];

      _drawFlowingDashes(
        canvas,
        from,
        to,
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..strokeWidth = t.lineWidth
          ..strokeCap = StrokeCap.round,
      );

      // Bounce ring (skip the terminal fade-out node).
      if (!nodes[i].isTerminal) {
        final ringColor = nodes[i].dampened
            ? AppColors.ink300
            : nodes[i].ghosted
                ? AppColors.blue300
                : _legColors[
                    nodes[i].bounceIndex.clamp(0, _legColors.length - 1)];
        canvas.drawCircle(
          to.toOffset(),
          t.bounceRingRadius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = ringColor.withValues(alpha: alpha),
        );
      }
    }
  }

  void _drawFlowingDashes(
      Canvas canvas, Vector2 from, Vector2 to, Paint paint) {
    const t = Tuning.trajectory;
    final delta = to - from;
    final length = delta.length;
    if (length < 1) return;
    final dir = delta / length;

    final period = t.dashLength + t.gapLength;
    // Flow: the dash pattern slides along the firing direction.
    var d = -(_dashPhase % period);
    while (d < length) {
      final start = d.clamp(0.0, length);
      final end = (d + t.dashLength).clamp(0.0, length);
      if (end > start) {
        canvas.drawLine(
          (from + dir * start).toOffset(),
          (from + dir * end).toOffset(),
          paint,
        );
      }
      d += period;
    }
  }
}
