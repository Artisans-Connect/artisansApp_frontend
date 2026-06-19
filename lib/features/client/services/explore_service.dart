import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cached_fetch.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/current_user.dart';

class ExploreService {
  static final ExploreService instance = ExploreService._();
  ExploreService._();

  final ApiClient _apiClient = ApiClient.instance;

  Future<List<Map<String, dynamic>>> getArtisans({
    String? categoryId,
    double? lat,
    double? lng,
    double radiusKm = 30,
    int limit = 50,
    bool forceRefresh = false,
    void Function(List<Map<String, dynamic>> fresh)? onRefreshed,
  }) async {
    final String cacheKey = CacheKeys.exploreNearby(
      categoryId: categoryId,
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      limit: limit,
    );

    final List<dynamic> raw = await CachedFetch.staleWhileRevalidate<List<dynamic>>(
      key: cacheKey,
      ttl: CacheKeys.exploreTtl,
      forceRefresh: forceRefresh,
      fetch: () => _fetchArtisansRaw(
        categoryId: categoryId,
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        limit: limit,
      ),
      onRefreshed: onRefreshed == null
          ? null
          : (List<dynamic> fresh) => onRefreshed(_castArtisanList(fresh)),
    );

    return _castArtisanList(raw);
  }

  Future<List<dynamic>> _fetchArtisansRaw({
    String? categoryId,
    double? lat,
    double? lng,
    required double radiusKm,
    required int limit,
  }) async {
    final queryParams = <String, String>{
      'radius_km': radiusKm.toString(),
      'limit': limit.toString(),
    };

    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['category_id'] = categoryId;
    }
    if (lat != null && lng != null) {
      queryParams['lat'] = lat.toString();
      queryParams['lng'] = lng.toString();
    }

    final queryStr = Uri(queryParameters: queryParams).query;
    final dynamic response = await _apiClient.get('/workers/nearby?$queryStr');

    if (response is List) return response;
    return <dynamic>[];
  }

  List<Map<String, dynamic>> _castArtisanList(List<dynamic> raw) {
    return raw
        .map((dynamic e) => Map<String, dynamic>.from(e as Map))
        .where((Map<String, dynamic> worker) {
          final String id = (worker['id'] ?? worker['worker_id'] ?? '').toString();
          return id.isNotEmpty && id != CurrentUser.id;
        })
        .toList();
  }
}
