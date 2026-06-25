import '../network/api_client.dart';

class SmartSearchIntent {
  final List<String> categoryIds;
  final List<String> categoryNames;
  final String refinedQuery;
  final String intentSummary;

  SmartSearchIntent({
    required this.categoryIds,
    required this.categoryNames,
    required this.refinedQuery,
    required this.intentSummary,
  });

  factory SmartSearchIntent.empty(String query) {
    return SmartSearchIntent(
      categoryIds: const <String>[],
      categoryNames: const <String>[],
      refinedQuery: query,
      intentSummary: '',
    );
  }
}

class SmartSearchService {
  static final SmartSearchService instance = SmartSearchService._();
  SmartSearchService._();

  final ApiClient _apiClient = ApiClient.instance;

  Future<SmartSearchIntent> parseIntent(String query) async {
    if (query.trim().isEmpty) {
      return SmartSearchIntent.empty(query);
    }

    try {
      final dynamic response = await _apiClient.post(
        '/search/parse-intent',
        body: <String, dynamic>{'query': query},
      );

      if (response is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response['data'] as Map<String, dynamic>? ?? response;
        final List<dynamic> categories = responseData['categories'] as List<dynamic>? ?? const <dynamic>[];
        final List<String> categoryIds = categories
            .map((dynamic c) => (c as Map<String, dynamic>)['id']?.toString() ?? '')
            .where((String id) => id.isNotEmpty)
            .toList();
        final List<String> categoryNames = categories
            .map((dynamic c) => (c as Map<String, dynamic>)['name']?.toString() ?? '')
            .where((String name) => name.isNotEmpty)
            .toList();

        return SmartSearchIntent(
          categoryIds: categoryIds,
          categoryNames: categoryNames,
          refinedQuery: (responseData['refinedQuery'] ?? query).toString(),
          intentSummary: (responseData['intentSummary'] ?? '').toString(),
        );
      }
    } catch (e) {
      print('SmartSearch parseIntent failed: $e');
    }

    return SmartSearchIntent.empty(query);
  }
}
