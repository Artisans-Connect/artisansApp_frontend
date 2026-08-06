import '../../shared/models/negotiation.dart';
import '../cache/cache_keys.dart';
import '../cache/cache_store.dart';
import '../network/api_client.dart';

class NegotiationService {
  NegotiationService._();
  static final NegotiationService instance = NegotiationService._();

  final ApiClient _api = ApiClient.instance;

  Future<Negotiation> createNegotiation({
    required String jobId,
    String? applicationId,
    required String type, // 'quote' | 'extra_charge' | 'completion_adjustment'
    required double initialAmount,
    String? description,
    String? idempotencyKey,
  }) async {
    final Map<String, String> headers = <String, String>{};
    if (idempotencyKey != null) {
      headers['Idempotency-Key'] = idempotencyKey;
    }

    final dynamic response = await _api.post(
      '/negotiations',
      body: <String, dynamic>{
        'jobId': jobId,
        'applicationId': applicationId,
        'type': type,
        'initialAmount': initialAmount,
        if (description != null) 'description': description,
      },
      headers: headers,
    );

    await CacheStore.instance.invalidatePrefix(CacheKeys.jobsMinePrefix);
    return Negotiation.fromJson(response as Map<String, dynamic>);
  }

  Future<List<Negotiation>> getJobNegotiations(String jobId) async {
    final dynamic response = await _api.get('/negotiations/job/$jobId');
    final List<dynamic> list = response as List<dynamic>;
    return list.map((dynamic item) => Negotiation.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Negotiation> getNegotiation(String id) async {
    final dynamic response = await _api.get('/negotiations/$id');
    return Negotiation.fromJson(response as Map<String, dynamic>);
  }

  Future<Negotiation> proposeAmount({
    required String negotiationId,
    required double amount,
    String? note,
  }) async {
    final dynamic response = await _api.post(
      '/negotiations/$negotiationId/propose',
      body: <String, dynamic>{
        'amount': amount,
        if (note != null) 'note': note,
      },
    );
    await CacheStore.instance.invalidatePrefix(CacheKeys.jobsMinePrefix);
    return Negotiation.fromJson(response as Map<String, dynamic>);
  }

  Future<Negotiation> acceptNegotiation(String negotiationId) async {
    final dynamic response = await _api.post('/negotiations/$negotiationId/accept');
    await CacheStore.instance.invalidatePrefix(CacheKeys.jobsMinePrefix);
    return Negotiation.fromJson(response as Map<String, dynamic>);
  }

  Future<Negotiation> rejectNegotiation({
    required String negotiationId,
    String? reason,
  }) async {
    final dynamic response = await _api.post(
      '/negotiations/$negotiationId/reject',
      body: <String, dynamic>{
        if (reason != null) 'reason': reason,
      },
    );
    await CacheStore.instance.invalidatePrefix(CacheKeys.jobsMinePrefix);
    return Negotiation.fromJson(response as Map<String, dynamic>);
  }
}
