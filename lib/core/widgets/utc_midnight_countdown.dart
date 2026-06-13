import 'dart:async';

import 'package:flutter/material.dart';

/// Live "resets in HH:MM:SS" countdown to the next UTC midnight — the
/// boundary the daily challenge and leaderboards roll on.
class UtcMidnightCountdown extends StatefulWidget {
  const UtcMidnightCountdown({super.key, this.style, this.prefix = ''});

  final TextStyle? style;
  final String prefix;

  @override
  State<UtcMidnightCountdown> createState() => _UtcMidnightCountdownState();
}

class _UtcMidnightCountdownState extends State<UtcMidnightCountdown> {
  Timer? _timer;
  late Duration _remaining = _toMidnight();

  static Duration _toMidnight() {
    final now = DateTime.now().toUtc();
    final next = DateTime.utc(now.year, now.month, now.day + 1);
    return next.difference(now);
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _remaining = _toMidnight());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return Text('${widget.prefix}$h:$m:$s', style: widget.style);
  }
}
