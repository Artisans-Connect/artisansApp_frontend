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

  Future<dynamic> acceptJob(String jobId) async {
    return await _api.post('/workers/accept/$jobId');
  }

  Future<dynamic> declineJob(String jobId) async {
    return await _api.post('/workers/decline/$jobId');
  }
}
