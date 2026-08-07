import 'package:supabase_flutter/supabase_flutter.dart';

class NegotiationRealtimeService {
  RealtimeChannel? _negotiationChannel;
  RealtimeChannel? _roundsChannel;
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
}
