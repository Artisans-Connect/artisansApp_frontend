import '../network/api_client.dart';

class JobsService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<dynamic> createJob(Map<String, dynamic> body) async {
    return await _apiClient.post('/jobs/create', body: body);
  }

  Future<List<dynamic>> getMyJobs({String? status}) async {
    String endpoint = '/jobs/mine';
    if (status != null && status.isNotEmpty) {
      endpoint += '?status=$status';
    }
    final response = await _apiClient.get(endpoint);
    return response as List<dynamic>;
  }

  Future<dynamic> cancelJob(dynamic id) async {
    return await _apiClient.post('/jobs/$id/cancel');
  }

  Future<dynamic> completeJob(dynamic id) async {
    return await _apiClient.post('/jobs/$id/complete');
  }

  Future<dynamic> getJobById(dynamic id) async {
    return await _apiClient.get('/jobs/$id');
  }
}
