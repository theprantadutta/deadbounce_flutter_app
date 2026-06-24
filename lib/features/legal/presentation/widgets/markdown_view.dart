import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// A small, theme-aware Markdown renderer for the legal documents.
///
/// Deliberately NOT a full CommonMark engine — it renders exactly the subset
/// used by `assets/legal/*.md`, styled in the Deadbounce type scale:
///   - `#` / `##` / `###` headings (Orbitron, amber)
///   - `-` / `*` bullet lists (neon chevron + reflowed text)
///   - `---` horizontal rules
///   - paragraphs, with inline `**bold**`
///
/// Blocks are reflowed: consecutive non-blank text lines join into one
/// paragraph/bullet (so the source can stay readable), a blank line or a new
/// marker starts a new block.
class MarkdownView extends StatelessWidget {
  const MarkdownView({super.key, required this.data, this.padding});

  final String data;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final blocks = _parse(data);
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      itemCount: blocks.length,
      itemBuilder: (context, i) => blocks[i].build(context, textTheme),
    );
  }

  static List<_Block> _parse(String source) {
    final blocks = <_Block>[];
    _Block? pending; // an open paragraph/bullet that text lines append to

    void flush() {
      if (pending != null) {
        blocks.add(pending!);
        pending = null;
      }
    }

    for (final raw in source.split('\n')) {
      final line = raw.trim();

      if (line.isEmpty) {
        flush();
        continue;
      }
      if (line == '---' || line == '***' || line == '___') {
        flush();
        blocks.add(const _Rule());
        continue;
      }
      if (line.startsWith('### ')) {
        flush();
        blocks.add(_Heading(line.substring(4).trim(), 3));
        continue;
      }
      if (line.startsWith('## ')) {
        flush();
        blocks.add(_Heading(line.substring(3).trim(), 2));
        continue;
      }
      if (line.startsWith('# ')) {
        flush();
        blocks.add(_Heading(line.substring(2).trim(), 1));
        continue;
      }
      if (line.startsWith('- ') || line.startsWith('* ')) {
        flush();
        pending = _Bullet(line.substring(2).trim());
        continue;
      }
      // Plain text — append to the open block (soft-wrap reflow) or start one.
      if (pending is _Bullet) {
        (pending! as _Bullet).text += ' $line';
      } else if (pending is _Paragraph) {
        (pending! as _Paragraph).text += ' $line';
      } else {
        pending = _Paragraph(line);
      }
    }
    flush();
    return blocks;
  }
}

/// Splits text on `**bold**` markers into styled spans.
List<TextSpan> _inlineSpans(String text, TextStyle? base, TextStyle? bold) {
  final parts = text.split('**');
  final spans = <TextSpan>[];
  for (var i = 0; i < parts.length; i++) {
    if (parts[i].isEmpty) continue;
    // Odd segments are between a pair of `**` → bold.
    spans.add(TextSpan(text: parts[i], style: i.isOdd ? bold : base));
  }
  return spans;
}

abstract class _Block {
  const _Block();
  Widget build(BuildContext context, TextTheme textTheme);
}

class _Heading extends _Block {
  const _Heading(this.text, this.level);
  final String text;
  final int level;

  @override
  Widget build(BuildContext context, TextTheme textTheme) {
    final (TextStyle? style, Color color, double top) = switch (level) {
      1 => (textTheme.headlineSmall, AppColors.amber300, AppSpacing.sm),
      2 => (textTheme.titleLarge, AppColors.amber300, AppSpacing.lg),
      _ => (textTheme.titleSmall, AppColors.blue300, AppSpacing.md),
    };
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: AppSpacing.xs),
      child: Text(text, style: style?.copyWith(color: color)),
    );
  }
}

class _Paragraph extends _Block {
  _Paragraph(this.text);
  String text;

  @override
  Widget build(BuildContext context, TextTheme textTheme) {
    final base = textTheme.bodyMedium;
    final bold = base?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text.rich(
        TextSpan(children: _inlineSpans(text, base, bold)),
      ),
    );
  }
}

class _Bullet extends _Block {
  _Bullet(this.text);
  String text;

  @override
  Widget build(BuildContext context, TextTheme textTheme) {
    final base = textTheme.bodyMedium;
    final bold = base?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.chevron_right,
                color: AppColors.amber400, size: 18),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text.rich(
              TextSpan(children: _inlineSpans(text, base, bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Rule extends _Block {
  const _Rule();

  @override
  Widget build(BuildContext context, TextTheme textTheme) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Divider(color: AppColors.outlineFaint, height: 1),
    );
  }
}
