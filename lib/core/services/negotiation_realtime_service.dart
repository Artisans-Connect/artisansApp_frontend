import 'package:supabase_flutter/supabase_flutter.dart';

class NegotiationRealtimeService {
  RealtimeChannel? _negotiationChannel;
  RealtimeChannel? _roundsChannel;
  RealtimeChannel? _jobNegotiationsChannel;
  RealtimeChannel? _jobRoundsChannel;
  void Function()? _onUpdate;

  void subscribeToNegotiation(
    String negotiationId, {
    required void Function() onUpdate,
  }) {
    unsubscribe();
    _onUpdate = onUpdate;

    final SupabaseClient client = Supabase.instance.client;

    // Listen to changes on the negotiations row
    _negotiationChannel = client
        .channel('negotiation-row-$negotiationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'negotiations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: negotiationId,
          ),
          callback: (PostgresChangePayload payload) {
            _onUpdate?.call();
          },
        )
        .subscribe();

    // Listen to new rounds added to the negotiation
    _roundsChannel = client
        .channel('negotiation-rounds-$negotiationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'negotiation_rounds',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'negotiation_id',
            value: negotiationId,
          ),
          callback: (PostgresChangePayload payload) {
            _onUpdate?.call();
          },
        )
        .subscribe();
  }

  void subscribeToJobNegotiations(
    String jobId, {
    required void Function() onUpdate,
  }) {
    unsubscribeJob();

    final SupabaseClient client = Supabase.instance.client;

    _jobNegotiationsChannel = client
        .channel('job-negotiations-$jobId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'negotiations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'job_id',
            value: jobId,
          ),
          callback: (PostgresChangePayload payload) {
            onUpdate();
          },
        )
        .subscribe();

    _jobRoundsChannel = client
        .channel('job-negotiation-rounds-$jobId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'negotiation_rounds',
          callback: (PostgresChangePayload payload) {
            onUpdate();
          },
        )
        .subscribe();
  }

  void unsubscribe() {
    final SupabaseClient client = Supabase.instance.client;
    if (_negotiationChannel != null) {
      client.removeChannel(_negotiationChannel!);
      _negotiationChannel = null;
    }
    if (_roundsChannel != null) {
      client.removeChannel(_roundsChannel!);
      _roundsChannel = null;
    }
    _onUpdate = null;
  }

  void unsubscribeJob() {
    final SupabaseClient client = Supabase.instance.client;
    if (_jobNegotiationsChannel != null) {
      client.removeChannel(_jobNegotiationsChannel!);
      _jobNegotiationsChannel = null;
    }
    if (_jobRoundsChannel != null) {
      client.removeChannel(_jobRoundsChannel!);
      _jobRoundsChannel = null;
    }
  }
}
