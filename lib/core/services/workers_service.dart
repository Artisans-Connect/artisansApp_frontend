import '../network/api_client.dart';

class WorkersService {
  final ApiClient _api = ApiClient.instance;

  Future<bool> getAvailability() async {
    final dynamic response = await _api.get('/workers/availability');
    final Map<String, dynamic> availability =
        Map<String, dynamic>.from(response as Map);
    return availability['is_available'] == true;
  }

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

  Future<Map<String, dynamic>> getStats() async {
    final dynamic response = await _api.get('/workers/me/stats');
    return Map<String, dynamic>.from(response as Map);
  }

  Future<dynamic> startJob(String jobId) async {
    return await _api.post('/workers/$jobId/start');
  }

  Future<dynamic> markOnTheWay(String jobId) async {
    return await _api.post('/workers/$jobId/on-way');
  }

  Future<dynamic> markArrived(String jobId) async {
    return await _api.post('/workers/$jobId/arrive');
  }

  Future<dynamic> cancelJob(String jobId, {String? reason}) async {
    return await _api.post(
      '/workers/$jobId/cancel',
      body: <String, dynamic>{
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  Future<dynamic> respondToTermination(
    String jobId, {
    required bool accept,
  }) async {
    return await _api.post(
      '/workers/$jobId/respond-termination',
      body: <String, dynamic>{'accept': accept},
    );
  }

  Future<dynamic> getHistory() async {
    return await _api.get('/workers/me/history');
  }

  Future<List<dynamic>> getJobRequests() async {
    final response = await _api.get('/workers/me/job-requests');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getApplications() async {
    final response = await _api.get('/workers/me/applications');
    return response as List<dynamic>;
  }

  Future<dynamic> getJobRequestById(String jobId) async {
    return await _api.get('/workers/me/job-requests/$jobId');
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

  Future<dynamic> applyToJob(String jobId, {String? message}) async {
    return await _api.post(
      '/workers/accept/$jobId',
      body: <String, dynamic>{
        if (message != null && message.trim().isNotEmpty)
          'message': message.trim(),
      },
    );
  }

  Future<dynamic> acceptJob(String jobId) => applyToJob(jobId);

  Future<dynamic> declineJob(String jobId) async {
    return await _api.post('/workers/decline/$jobId');
  }

  Future<Map<String, dynamic>> getEarnings() async {
    final dynamic response = await _api.get('/workers/me/earnings');
    return Map<String, dynamic>.from(response as Map);
  }
}
