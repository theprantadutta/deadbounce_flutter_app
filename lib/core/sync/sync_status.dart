import 'package:flutter/foundation.dart';

@immutable
class SyncStatus {
  const SyncStatus({
    this.pendingCount = 0,
    this.failedCount = 0,
    this.lastSyncedAt,
    this.isSyncing = false,
  });

  final int pendingCount;
  final int failedCount;
  final DateTime? lastSyncedAt;
  final bool isSyncing;

  bool get hasPendingWork => pendingCount > 0 || failedCount > 0;

  @override
  bool operator ==(Object other) =>
      other is SyncStatus &&
      other.pendingCount == pendingCount &&
      other.failedCount == failedCount &&
      other.lastSyncedAt == lastSyncedAt &&
      other.isSyncing == isSyncing;

  @override
  int get hashCode =>
      Object.hash(pendingCount, failedCount, lastSyncedAt, isSyncing);
}

/// Drives the "sync pending" indicator in Profile/Settings. Updated by
/// the SyncWorker after every drain.
class SyncStatusNotifier extends ValueNotifier<SyncStatus> {
  SyncStatusNotifier() : super(const SyncStatus());
}
