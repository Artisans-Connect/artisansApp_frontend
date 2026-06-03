import '../cache/cache_keys.dart';
import '../cache/cached_fetch.dart';
import '../network/api_client.dart';

class CategoriesService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<List<dynamic>> listCategories({bool forceRefresh = false}) async {
    return CachedFetch.get<List<dynamic>>(
      key: CacheKeys.categories,
      ttl: CacheKeys.categoriesTtl,
      forceRefresh: forceRefresh,
      fetch: () async {
        final response = await _apiClient.get('/categories');
        return response as List<dynamic>;
      },
    );
  }
}
