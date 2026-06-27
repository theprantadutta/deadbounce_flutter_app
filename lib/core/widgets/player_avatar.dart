import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A circular player avatar: shows the account photo (e.g. a Google profile
/// picture) when one is available, with a graceful person-icon fallback when
/// there's no photo, while it loads, or on any network/decode error. Never
/// blocks — offline it simply falls back to the icon (a previously-loaded photo
/// still paints from the in-memory image cache).
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.photoUrl,
    this.size = 48,
    this.iconColor = AppColors.amber300,
    this.background = AppColors.ink800,
  });

  final String? photoUrl;
  final double size;
  final Color iconColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final fallback = Container(
      color: background,
      alignment: Alignment.center,
      child: Icon(Icons.person, size: size * 0.52, color: iconColor),
    );

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url == null || url.isEmpty
            ? fallback
            : Image.network(
                url,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => fallback,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : fallback,
              ),
      ),
    );
  }
}
