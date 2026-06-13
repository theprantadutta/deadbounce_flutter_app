import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../engine/physics/wall_segment.dart';
import 'deadbounce_game.dart';

/// Renders the arena from its wall segments: dark floor, blueprint grid,
/// glowing amber walls (the ricochet surfaces) — and turret-dampened
/// sections in dead gray-blue so the tactical state is readable at a
/// glance.
class ArenaComponent extends PositionComponent
    with HasGameReference<DeadbounceGame> {
  ArenaComponent({required this.segments})
      : super(
          size: Vector2(DeadbounceGame.arenaWidth, DeadbounceGame.arenaHeight),
          anchor: Anchor.topLeft,
          position: Vector2.zero(),
          priority: 0,
        );

  final List<WallSegment> segments;

  static const double _wallThickness = 12;
  static const double _gridSpacing = 80;

  late final Paint _floorPaint = Paint()..color = AppColors.ink900;
  late final Paint _gridPaint = Paint()
    ..color = AppColors.blue500.withValues(alpha: 0.07)
    ..strokeWidth = 1;
  late final Paint _wallPaint = Paint()
    ..color = AppColors.amber500
    ..strokeWidth = _wallThickness
    ..strokeCap = StrokeCap.round;
  late final Paint _wallGlowPaint = Paint()
    ..color = AppColors.amber500.withValues(alpha: 0.4)
    ..strokeWidth = _wallThickness * 2.4
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  late final Paint _dampenedPaint = Paint()
    ..color = AppColors.ink300
    ..strokeWidth = _wallThickness
    ..strokeCap = StrokeCap.round;
  late final Paint _obstaclePaint = Paint()
    ..color = AppColors.blue500
    ..strokeWidth = _wallThickness * 0.8
    ..strokeCap = StrokeCap.round;
  late final Paint _obstacleGlowPaint = Paint()
    ..color = AppColors.blue500.withValues(alpha: 0.35)
    ..strokeWidth = _wallThickness * 1.8
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _floorPaint);

    for (var x = _gridSpacing; x < size.x; x += _gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _gridPaint);
    }
    for (var y = _gridSpacing; y < size.y; y += _gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _gridPaint);
    }

    for (final segment in segments) {
      final a = segment.a.toOffset();
      final b = segment.b.toOffset();

      if (segment.isDampened) {
        canvas.drawLine(a, b, _dampenedPaint);
      } else if (segment.isBoundary) {
        canvas.drawLine(a, b, _wallGlowPaint);
        canvas.drawLine(a, b, _wallPaint);
      } else {
        canvas.drawLine(a, b, _obstacleGlowPaint);
        canvas.drawLine(a, b, _obstaclePaint);
      }
    }
  }
}
