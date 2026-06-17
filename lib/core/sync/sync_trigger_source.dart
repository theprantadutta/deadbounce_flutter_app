import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import '../logging/app_logger.dart';

/// Why a sync was requested — useful in logs.
enum SyncTrigger { foreground, connectivityRegained, periodic, manual }

/// Merges the four spec-mandated sync triggers into one stream:
/// app foreground, connectivity regained (offline→online edge), a
/// periodic timer while the app is resumed, and manual requests
/// (run end, snapshot restore, retry button).
class SyncTriggerSource with WidgetsBindingObserver {
  SyncTriggerSource({
    Connectivity? connectivity,
    this.periodicInterval = const Duration(minutes: 2, seconds: 30),
  }) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final Duration periodicInterval;

  final _controller = StreamController<SyncTrigger>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodicTimer;
  bool _wasOffline = false;

  Stream<SyncTrigger> get triggers => _controller.stream;

  void _emit(SyncTrigger trigger) {
    AppLogger.talker.debug('[sync] trigger: ${trigger.name}');
    _controller.add(trigger);
  }

  void start() {
    WidgetsBinding.instance.addObserver(this);

    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final offline =
          results.isEmpty || results.every((r) => r == ConnectivityResult.none);
      if (_wasOffline && !offline) {
        _emit(SyncTrigger.connectivityRegained);
      }
      _wasOffline = offline;
    });

    _startPeriodic();
  }

  void requestManual() => _emit(SyncTrigger.manual);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _emit(SyncTrigger.foreground);
      _startPeriodic();
    } else if (state == AppLifecycleState.paused) {
      // No background timers — battery first; foreground re-arms it.
      _periodicTimer?.cancel();
      _periodicTimer = null;
    }
  }

  void _startPeriodic() {
    _periodicTimer ??= Timer.periodic(
      periodicInterval,
      (_) => _emit(SyncTrigger.periodic),
    );
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _periodicTimer?.cancel();
    await _connectivitySub?.cancel();
    await _controller.close();
  }
}
