import 'package:flutter/material.dart';

/// A headline that always fits its width on one line: it scales DOWN to
/// fit narrow screens but never grows past its natural size. Use for big
/// wordmarks / titles (the Orbitron display styles) that would otherwise
/// wrap or overflow on small-width devices.
class FittedHeadline extends StatelessWidget {
  const FittedHeadline(
    this.text, {
    super.key,
    required this.style,
    this.textAlign = TextAlign.center,
    this.alignment = Alignment.center,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: Text(text, style: style, textAlign: textAlign, maxLines: 1),
      ),
    );
  }
}
