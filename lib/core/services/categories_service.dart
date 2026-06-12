import '../cache/cache_keys.dart';
import '../cache/cached_fetch.dart';
import '../network/api_client.dart';

class CategoriesService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Fetches all active categories with their nested subcategories.
  /// 
  /// The returned list contains category objects with the structure:
  /// ```
  /// {
  ///   'id': uuid,
  ///   'name': string,
  ///   'slug': string,
  ///   'icon_name': string,
  ///   'color_hex': string (e.g., '#4648D4'),
  ///   'description': string,
  ///   'sort_order': number,
  ///   'subcategories': [
  ///     {
  ///       'id': uuid,
  ///       'name': string,
  ///       'slug': string,
  ///       'description': string,
  ///       'sort_order': number
  ///     },
  ///     ...
  ///   ]
  /// }
  /// ```
  /// 
  /// Results are cached according to [CacheKeys.categoriesTtl].
  /// Pass [forceRefresh] = true to bypass the cache and fetch fresh data.
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

  /// Gets subcategories for a specific category by ID or slug.
  /// 
  /// First attempts to extract subcategories from cached categories data.
  /// If not found in cache, returns an empty list.
  Future<List<dynamic>> getSubcategoriesFor(String? categorySlugOrId) async {
    if (categorySlugOrId == null || categorySlugOrId.isEmpty) {
      return <dynamic>[];
    }

    try {
      final List<dynamic> categories = await listCategories();
      
      // Find the category by slug or id
      final dynamic category = categories.firstWhere(
        (dynamic c) =>
            (c is Map && (c['slug'] == categorySlugOrId || c['id'] == categorySlugOrId)) ||
            (c is Map && c['categoryKey'] == categorySlugOrId),
        orElse: () => null,
      );

      if (category is Map && category['subcategories'] is List) {
        return category['subcategories'] as List<dynamic>;
      }

      return <dynamic>[];
    } catch (e) {
      return <dynamic>[];
    }
  }
}
