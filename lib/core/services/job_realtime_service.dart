import 'package:supabase_flutter/supabase_flutter.dart';

/// Listens to a single job row via Supabase Realtime (RLS: client owns job).
class JobRealtimeService {
  RealtimeChannel? _channel;
  void Function(Map<String, dynamic> job)? _onUpdate;

  void subscribeToJob(
    String jobId, {
    required void Function(Map<String, dynamic> job) onUpdate,
  }) {
    unsubscribe();
    _onUpdate = onUpdate;

    _channel = Supabase.instance.client
        .channel('job-$jobId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'jobs',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: jobId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record.isNotEmpty) {
              _onUpdate?.call(Map<String, dynamic>.from(record));
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
    _onUpdate = null;
  }
}
