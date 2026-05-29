import '../network/api_client.dart';

class CategoriesService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<List<dynamic>> listCategories() async {
    final response = await _apiClient.get('/categories');
    return response as List<dynamic>;
  }
}
