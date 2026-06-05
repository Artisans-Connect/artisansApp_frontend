import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerDispatchRealtimeService {
  RealtimeChannel? _channel;

  void subscribe({
    required String workerId,
    required void Function(String jobId, DateTime? expiresAt) onDispatch,
    required void Function(String jobId) onClosed,
  }) {
    unsubscribe();

    _channel = Supabase.instance.client
        .channel('worker-dispatches-$workerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'job_dispatches',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'worker_id',
            value: workerId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isEmpty) return;
            final String? jobId = record['job_id'] as String?;
            if (jobId == null || jobId.isEmpty) return;
            final String status =
                (record['status'] as String? ?? '').toLowerCase();

            if (status == 'sent' || status == 'seen') {
              onDispatch(jobId, _parseDate(record['expires_at']));
            } else if (status == 'accepted' ||
                status == 'declined' ||
                status == 'expired') {
              onClosed(jobId);
            }
          },
        )
        .subscribe();
  }

  void unsubscribe() {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
      _channel = null;
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
