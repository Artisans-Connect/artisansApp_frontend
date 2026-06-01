import '../../../core/network/api_client.dart';

class ExploreService {
  static final ExploreService instance = ExploreService._();
  ExploreService._();

  final ApiClient _apiClient = ApiClient.instance;

  Future<List<Map<String, dynamic>>> getArtisans({
    String? categoryId,
    double? lat,
    double? lng,
    double radiusKm = 15,
    int limit = 20,
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
    
    if (response is List) {
      // Cast the dynamic items to Map<String, dynamic> safely
      return response.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return <Map<String, dynamic>>[];
  }
}
