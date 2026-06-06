import '../cache/cache_keys.dart';
import '../cache/cache_store.dart';
import '../cache/cached_fetch.dart';
import '../network/api_client.dart';

class JobsService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<void> _invalidateJobsCache() async {
    await CacheStore.instance.invalidatePrefix(CacheKeys.jobsMinePrefix);
  }

  Future<dynamic> createJob(
    Map<String, dynamic> body, {
    String? idempotencyKey,
  }) async {
    final dynamic result = await _apiClient.post(
      '/jobs/create',
      body: body,
      extraHeaders: idempotencyKey != null
          ? {'Idempotency-Key': idempotencyKey}
          : null,
    );
    await _invalidateJobsCache();
    return result;
  }

  Future<List<dynamic>> getMyJobs({
    String? status,
    bool forceRefresh = false,
  }) async {
    final String cacheKey = CacheKeys.jobsMine(status: status);
    return CachedFetch.get<List<dynamic>>(
      key: cacheKey,
      ttl: CacheKeys.jobsTtl,
      forceRefresh: forceRefresh,
      fetch: () async {
        String endpoint = '/jobs/mine';
        if (status != null && status.isNotEmpty) {
          endpoint += '?status=$status';
        }
        final response = await _apiClient.get(endpoint);
        return response as List<dynamic>;
      },
    );
  }

  Future<dynamic> cancelJob(dynamic id) async {
    final dynamic result = await _apiClient.post('/jobs/$id/cancel');
    await _invalidateJobsCache();
    return result;
  }

  Future<dynamic> requestAnotherWorker(dynamic id) async {
    final dynamic result =
        await _apiClient.post('/jobs/$id/request-another-worker');
    await _invalidateJobsCache();
    return result;
  }

  Future<dynamic> completeJob(dynamic id, {Map<String, dynamic>? body}) async {
    final dynamic result = await _apiClient.post(
      '/jobs/$id/complete',
      body: body,
    );
    await _invalidateJobsCache();
    return result;
  }

  Future<dynamic> getJobById(dynamic id) async {
    return await _apiClient.get('/jobs/$id');
  }

  Future<dynamic> getMatchingProgress(dynamic id) async {
    return await _apiClient.get('/jobs/$id/matching-progress');
  }
}
