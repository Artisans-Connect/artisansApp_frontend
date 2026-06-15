import '../cache/cache_keys.dart';
import '../cache/cache_store.dart';
import '../network/api_client.dart';

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
}
