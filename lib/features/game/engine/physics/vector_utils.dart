import 'dart:math' as math;

import 'package:flame/components.dart';

extension Vector2Rotation on Vector2 {
  /// Rotates this vector in place by [radians] (counter-clockwise in
  /// screen coords where y grows downward).
  void rotateBy(double radians) {
    final cos = math.cos(radians);
    final sin = math.sin(radians);
    final newX = x * cos - y * sin;
    final newY = x * sin + y * cos;
    setValues(newX, newY);
  }

  /// A rotated copy.
  Vector2 rotatedBy(double radians) => clone()..rotateBy(radians);
}
