import '../cache/cache_keys.dart';
import '../cache/cache_store.dart';
import '../cache/cached_fetch.dart';
import '../network/api_client.dart';

class ChatService {
  final ApiClient _api = ApiClient.instance;

  Future<dynamic> getConversations({
    bool forceRefresh = false,
    void Function(dynamic fresh)? onRefreshed,
  }) async {
    return CachedFetch.staleWhileRevalidate<dynamic>(
      key: CacheKeys.chatConversations,
      ttl: CacheKeys.chatTtl,
      forceRefresh: forceRefresh,
      fetch: () => _api.get('/chat'),
      onRefreshed: onRefreshed,
    );
  }

  Future<dynamic> getMessages(String conversationId) async {
    return await _api.get('/chat/$conversationId/messages');
  }

  Future<dynamic> createDirectConversation(String workerId) async {
    final dynamic result = await _api.post(
      '/chat/direct',
      body: <String, dynamic>{'worker_id': workerId},
    );
    await CacheStore.instance.remove(CacheKeys.chatConversations);
    return result;
  }

  Future<dynamic> sendMessage(
    String conversationId,
    String content, {
    List<String>? imageUrls,
  }) async {
    final dynamic result = await _api.post('/chat/$conversationId/messages', body: {
      'content': content,
      if (imageUrls != null) 'image_urls': imageUrls,
    });
    await CacheStore.instance.remove(CacheKeys.chatConversations);
    return result;
  }
}
