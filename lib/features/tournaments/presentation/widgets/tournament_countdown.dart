import 'dart:async';

import 'package:flutter/material.dart';

/// A live "Ends in 2d 3h" / "Ends in 5h 12m" / "Ended" label that ticks down
/// to [endsAt]. Updates once a second.
class TournamentCountdown extends StatefulWidget {
  const TournamentCountdown({
    super.key,
    required this.endsAt,
    this.style,
    this.prefix = 'Ends in ',
    this.endedLabel = 'Ended',
  });

  final DateTime endsAt;
  final TextStyle? style;
  final String prefix;
  final String endedLabel;

  @override
  State<TournamentCountdown> createState() => _TournamentCountdownState();
}

class _TournamentCountdownState extends State<TournamentCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.endsAt.difference(DateTime.now().toUtc());
    final text = remaining.isNegative
        ? widget.endedLabel
        : '${widget.prefix}${_format(remaining)}';
    return Text(text, style: widget.style);
  }

  static String _format(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    if (days > 0) return '${days}d ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }
}
