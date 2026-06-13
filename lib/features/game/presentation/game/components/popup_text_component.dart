import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/painting.dart';

import '../../../../../core/theme/app_colors.dart';

/// Punchy scale-in popup text: bounce counters ("x3") riding bullets and
/// chain labels ("RICOCHET RAMPAGE"). Base styles are pre-baked once —
/// constructing fresh styles per spawn (especially via google_fonts)
/// stutters; each instance only clones a color with alpha while fading.
class PopupTextComponent extends TextComponent implements OpacityProvider {
  PopupTextComponent.bounceCounter(String text, Vector2 position)
      : this._(text, position, _bounceBase, riseDistance: 36, life: 0.5);

  PopupTextComponent.chainLabel(String text, Vector2 position)
      : this._(text, position, _chainBase, riseDistance: 56, life: 0.9);

  PopupTextComponent._(
    String text,
    Vector2 position,
    TextStyle baseStyle, {
    required this._riseDistance,
    required this._life,
  })  : _baseStyle = baseStyle,
        super(
          text: text,
          textRenderer: TextPaint(style: baseStyle),
          position: position,
          anchor: Anchor.center,
          priority: 90,
        );

  final TextStyle _baseStyle;
  final double _riseDistance;
  final double _life;
  double _opacity = 1;

  static const TextStyle _bounceBase = TextStyle(
    fontFamily: 'monospace',
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.amber300,
    letterSpacing: 1.2,
  );

  static const TextStyle _chainBase = TextStyle(
    fontFamily: 'monospace',
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: AppColors.blue300,
    letterSpacing: 2.5,
    shadows: [Shadow(color: AppColors.blue700, blurRadius: 16)],
  );

  @override
  double get opacity => _opacity;

  @override
  set opacity(double value) {
    _opacity = value.clamp(0, 1);
    textRenderer = TextPaint(
      style: _baseStyle.copyWith(
        color: _baseStyle.color!.withValues(alpha: _opacity),
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    scale = Vector2.all(0.2);
    addAll([
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.18, curve: Curves.easeOutBack),
      ),
      MoveByEffect(
        Vector2(0, -_riseDistance),
        EffectController(duration: _life, curve: Curves.easeOut),
      ),
      OpacityEffect.fadeOut(
        EffectController(startDelay: _life * 0.55, duration: _life * 0.45),
        target: this,
      ),
      RemoveEffect(delay: _life + 0.05),
    ]);
  }
}
