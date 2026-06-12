import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../../../../core/theme/app_colors.dart';

/// The empty Deadbounce arena — the canvas the ricochet mechanic will be
/// built on next.
///
/// Uses a fixed-resolution camera ([arenaWidth] x [arenaHeight] logical
/// units) so the arena renders identically across screen sizes and aspect
/// ratios: Flame letterboxes the difference instead of stretching or
/// cropping gameplay space.
class DeadbounceGame extends FlameGame {
  DeadbounceGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: arenaWidth,
            height: arenaHeight,
          ),
        );

  /// Logical arena resolution — portrait, 9:16.
  static const double arenaWidth = 720;
  static const double arenaHeight = 1280;

  @override
  Color backgroundColor() => AppColors.ink950;

  @override
  Future<void> onLoad() async {
    // World origin is the arena center; walls are placed symmetrically.
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2.zero();

    world.add(ArenaComponent());
  }
}

/// Renders the arena: dark floor, a faint blueprint grid, and the four
/// boundary walls in brand amber with a neon glow — the surfaces bullets
/// will ricochet off.
class ArenaComponent extends PositionComponent {
  ArenaComponent()
      : super(
          size: Vector2(DeadbounceGame.arenaWidth, DeadbounceGame.arenaHeight),
          anchor: Anchor.center,
          position: Vector2.zero(),
        );

  static const double _wallThickness = 14;
  static const double _gridSpacing = 80;

  late final Rect _bounds;
  late final Paint _floorPaint;
  late final Paint _gridPaint;
  late final Paint _wallPaint;
  late final Paint _wallGlowPaint;
  late final Paint _cornerPaint;

  @override
  Future<void> onLoad() async {
    _bounds = Rect.fromLTWH(0, 0, size.x, size.y);

    _floorPaint = Paint()..color = AppColors.ink900;

    _gridPaint = Paint()
      ..color = AppColors.blue500.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    _wallPaint = Paint()
      ..color = AppColors.amber500
      ..style = PaintingStyle.stroke
      ..strokeWidth = _wallThickness;

    _wallGlowPaint = Paint()
      ..color = AppColors.amber500.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _wallThickness * 2.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    _cornerPaint = Paint()
      ..color = AppColors.blue400
      ..style = PaintingStyle.stroke
      ..strokeWidth = _wallThickness
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
  }

  @override
  void render(Canvas canvas) {
    // Floor
    canvas.drawRect(_bounds, _floorPaint);

    // Blueprint grid
    for (double x = _gridSpacing; x < size.x; x += _gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _gridPaint);
    }
    for (double y = _gridSpacing; y < size.y; y += _gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _gridPaint);
    }

    // Walls: glow pass first, then the crisp amber stroke on top. The
    // stroke is inset by half its thickness so the full wall body sits
    // inside the playable bounds.
    final wallRect = _bounds.deflate(_wallThickness / 2);
    canvas.drawRect(wallRect, _wallGlowPaint);
    canvas.drawRect(wallRect, _wallPaint);

    // Electric-blue corner accents — a hint of the ricochet trail to come.
    const cornerLength = 64.0;
    final c = wallRect;
    final corners = <List<Offset>>[
      [c.topLeft, c.topLeft + const Offset(cornerLength, 0)],
      [c.topLeft, c.topLeft + const Offset(0, cornerLength)],
      [c.topRight, c.topRight + const Offset(-cornerLength, 0)],
      [c.topRight, c.topRight + const Offset(0, cornerLength)],
      [c.bottomLeft, c.bottomLeft + const Offset(cornerLength, 0)],
      [c.bottomLeft, c.bottomLeft + const Offset(0, -cornerLength)],
      [c.bottomRight, c.bottomRight + const Offset(-cornerLength, 0)],
      [c.bottomRight, c.bottomRight + const Offset(0, -cornerLength)],
    ];
    for (final segment in corners) {
      canvas.drawLine(segment[0], segment[1], _cornerPaint);
    }
  }
}
