import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in an external browser. If no browser can be launched (or it
/// throws), it falls back to copying the link to the clipboard and showing a
/// snackbar — so the link is always useful. Reused by Credits and Settings.
Future<void> openExternalLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  var launched = false;
  try {
    launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    launched = false;
  }
  if (launched) return;
  await Clipboard.setData(ClipboardData(text: url));
  messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text('Link copied: $url')));
}
