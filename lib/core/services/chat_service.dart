import '../network/api_client.dart';

class ChatService {
  final ApiClient _api = ApiClient.instance;

  Future<dynamic> getConversations() async {
    return await _api.get('/chat');
  }

  Future<dynamic> getMessages(String conversationId) async {
    return await _api.get('/chat/$conversationId/messages');
  }

  Future<dynamic> sendMessage(String conversationId, String content, {List<String>? imageUrls}) async {
    return await _api.post('/chat/$conversationId/messages', body: {
      'content': content,
      if (imageUrls != null) 'image_urls': imageUrls,
    });
  }
}
