class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.isMine,
    this.imageUrls,
  });

  final String id;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isMine;
  final List<String>? imageUrls;

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['created_at'] as String),
      isMine: json['sender_id'] == currentUserId,
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'content': content,
      'created_at': sentAt.toIso8601String(),
      'image_urls': imageUrls,
    };
  }
}
