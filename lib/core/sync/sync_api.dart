import 'dart:convert';

import '../database/app_database.dart';
import '../network/api_client.dart';

/// Per-event outcome from POST /sync/batch.
/// Status: applied | duplicate | rejected | retry.
class SyncEventResult {
  const SyncEventResult({required this.id, required this.status, this.error});

  final String id;
  final String status;
  final String? error;

  bool get isSettled => status == 'applied' || status == 'duplicate';
  bool get isRejected => status == 'rejected';
}

/// Remote datasource for the sync endpoints. Maps wire shapes only —
/// retry/backoff policy lives in the SyncWorker.
class SyncApi {
  SyncApi(this._apiClient);

  final ApiClient _apiClient;

  /// Sends one outbox batch. Throws [ApiException] on transport/server
  /// failure (the whole batch retries).
  Future<List<SyncEventResult>> sendBatch(List<SyncOutboxRow> events) async {
    final json = await _apiClient.post('/sync/batch', body: {
      'events': [
        for (final e in events)
          {
            'id': e.id,
            'entity_type': e.entityType,
            'operation': e.operation,
            'payload': jsonDecode(e.payload),
            'created_at': e.createdAt,
          },
      ],
    });

    final results = (json['results'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((r) => SyncEventResult(
              id: r['id'] as String,
              status: r['status'] as String? ?? 'retry',
              error: r['error'] as String?,
            ))
        .toList();
    return results;
  }

  /// The one-time restore pull.
  Future<Map<String, dynamic>> fetchSnapshot() => _apiClient.get('/sync/snapshot');
}
