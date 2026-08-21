import 'package:artisans_app/core/cache/cache_keys.dart';
import 'package:artisans_app/core/cache/cache_store.dart';
import 'package:artisans_app/core/network/api_client.dart';

class ApplicationsService {
  final ApiClient _api = ApiClient.instance;

  Future<List<dynamic>> listForJob(String jobId) async {
    final dynamic response = await _api.get('/jobs/$jobId/applications');
    return response as List<dynamic>;
  }

  Future<dynamic> acceptApplication({
    required String jobId,
    required String applicationId,
  }) async {
    final dynamic result =
        await _api.post('/jobs/$jobId/applications/$applicationId/accept');
    await CacheStore.instance.invalidatePrefix(CacheKeys.jobsMinePrefix);
    return result;
  }

  Future<dynamic> counterApplication({
    required String jobId,
    required String applicationId,
    required double counterRate,
  }) async {
    final dynamic result = await _api.post(
      '/jobs/$jobId/applications/$applicationId/counter',
      body: <String, dynamic>{
        'counterRate': counterRate,
      },
    );
    await CacheStore.instance.invalidatePrefix(CacheKeys.jobsMinePrefix);
    return result;
  }

  Future<dynamic> acceptCounterOffer({
    required String applicationId,
  }) async {
    final dynamic result = await _api.post(
      '/workers/applications/$applicationId/accept-counter',
    );
    await CacheStore.instance.invalidatePrefix(CacheKeys.jobsMinePrefix);
    return result;
  }
}

