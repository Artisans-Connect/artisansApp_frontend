import 'package:artisans_app/core/network/api_client.dart';
import 'package:artisans_app/core/cache/cache_keys.dart';
import 'package:artisans_app/core/cache/cache_store.dart';

class ReviewsService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<dynamic> createReview(Map<String, dynamic> body) async {
    final dynamic result = await _apiClient.post('/reviews', body: body);
    await CacheStore.instance.invalidatePrefix(CacheKeys.jobsMinePrefix);
    await CacheStore.instance.invalidatePrefix(CacheKeys.explorePrefix);
    await CacheStore.instance.remove(CacheKeys.profileMe);
    return result;
  }

  Future<List<dynamic>> getWorkerReviews(dynamic workerId) async {
    final response = await _apiClient.get('/reviews/worker/$workerId');
    return response as List<dynamic>;
  }
}
