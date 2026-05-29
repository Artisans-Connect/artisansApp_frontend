import '../network/api_client.dart';

class ReviewsService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<dynamic> createReview(Map<String, dynamic> body) async {
    return await _apiClient.post('/reviews', body: body);
  }

  Future<List<dynamic>> getWorkerReviews(dynamic workerId) async {
    final response = await _apiClient.get('/reviews/worker/$workerId');
    return response as List<dynamic>;
  }
}
