import '../network/api_client.dart';

class WorkersService {
  final ApiClient _api = ApiClient.instance;

  Future<dynamic> updateLocation(double lat, double lng) async {
    return await _api.put('/workers/location', body: {
      'current_lat': lat,
      'current_lng': lng,
    });
  }

  Future<dynamic> toggleAvailability(bool isAvailable) async {
    return await _api.put('/workers/availability', body: {
      'is_available': isAvailable,
    });
  }

  Future<dynamic> getActiveJob() async {
    return await _api.get('/workers/me/active-job');
  }

  Future<dynamic> startJob(String jobId) async {
    return await _api.post('/workers/$jobId/start');
  }

  Future<dynamic> getHistory() async {
    return await _api.get('/workers/me/history');
  }

  Future<List<dynamic>> getJobRequests() async {
    final response = await _api.get('/workers/me/job-requests');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getNearby({
    required String categoryId,
    required double lat,
    required double lng,
    double radiusKm = 15,
  }) async {
    final response = await _api.get(
      '/workers/nearby?category_id=$categoryId&lat=$lat&lng=$lng&radius_km=$radiusKm',
    );
    return response as List<dynamic>;
  }

  Future<dynamic> acceptJob(String jobId) async {
    return await _api.post('/workers/accept/$jobId');
  }

  Future<dynamic> declineJob(String jobId) async {
    return await _api.post('/workers/decline/$jobId');
  }
}
