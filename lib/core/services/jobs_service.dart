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
    int? limit,
    int? offset,
    bool forceRefresh = false,
  }) async {
    final String cacheKey = CacheKeys.jobsMine(status: status) +
        (limit != null ? '_l${limit}_o$offset' : '');
    return CachedFetch.get<List<dynamic>>(
      key: cacheKey,
      ttl: CacheKeys.jobsTtl,
      forceRefresh: forceRefresh,
      fetch: () async {
        String endpoint = '/jobs/mine';
        final params = <String>[];
        if (status != null && status.isNotEmpty) {
          params.add('status=$status');
        }
        if (limit != null) {
          params.add('limit=$limit');
        }
        if (offset != null) {
          params.add('offset=$offset');
        }
        if (params.isNotEmpty) {
          endpoint += '?${params.join('&')}';
        }
        final response = await _apiClient.get(endpoint);
        return response as List<dynamic>;
      },
    );
  }

  Future<Map<String, int>> getMyJobsCounts({bool forceRefresh = false}) async {
    final String cacheKey = '${CacheKeys.jobsMinePrefix}_counts';
    final dynamic response = await CachedFetch.get<dynamic>(
      key: cacheKey,
      ttl: CacheKeys.jobsTtl,
      forceRefresh: forceRefresh,
      fetch: () async {
        return await _apiClient.get('/jobs/mine/counts');
      },
    );
    final Map<String, dynamic> rawCounts =
        Map<String, dynamic>.from(response as Map);
    return rawCounts.map((String key, dynamic value) =>
        MapEntry<String, int>(key, value as int? ?? 0));
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

  Future<dynamic> approveCompletion(dynamic id) async {
    final dynamic result = await _apiClient.post('/jobs/$id/approve-completion');
    await _invalidateJobsCache();
    return result;
  }

  Future<dynamic> reopenJob(
    dynamic id, {
    Map<String, dynamic>? body,
  }) async {
    final dynamic result = await _apiClient.post(
      '/jobs/$id/reopen',
      body: body,
    );
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

  /// Either party confirms the work is finished. Stops the settlement clock
  /// (work_ended_at) without changing the job status.
  Future<dynamic> confirmWorkDone(dynamic id) async {
    final dynamic result =
        await _apiClient.post('/jobs/$id/confirm-work-done');
    await _invalidateJobsCache();
    return result;
  }

  Future<dynamic> getJobById(dynamic id) async {
    return await _apiClient.get('/jobs/$id');
  }

  Future<dynamic> getMatchingProgress(dynamic id) async {
    return await _apiClient.get('/jobs/$id/matching-progress');
  }

  Future<dynamic> getJobApplications(dynamic id) async {
    return await _apiClient.get('/jobs/$id/applications');
  }

  Future<dynamic> acceptApplication(dynamic id, dynamic applicationId) async {
    final dynamic result = await _apiClient.post(
      '/jobs/$id/applications/$applicationId/accept',
    );
    await _invalidateJobsCache();
    return result;
  }

  /// Preview what happens if the client cancels this job
  Future<dynamic> getCancellationPreview(dynamic id) async {
    return await _apiClient.get('/jobs/$id/cancellation-preview');
  }

  /// Cancel a job with optional reason
  Future<dynamic> cancelJobWithReason(dynamic id, {String? reason}) async {
    final dynamic result = await _apiClient.post(
      '/jobs/$id/cancel',
      body: reason != null ? {'reason': reason} : null,
    );
    await _invalidateJobsCache();
    return result;
  }

  /// Request termination for in-progress jobs (dispute workflow)
  Future<dynamic> requestTermination(dynamic id, {String? reason}) async {
    final dynamic result = await _apiClient.post(
      '/jobs/$id/request-termination',
      body: reason != null ? {'reason': reason} : null,
    );
    await _invalidateJobsCache();
    return result;
  }
}
