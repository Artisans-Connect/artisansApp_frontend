enum MessageStatus { pending, sent, failed }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.isMine,
    this.imageUrls,
    this.status = MessageStatus.sent,
  });

  final String id;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isMine;
  final List<String>? imageUrls;
  final MessageStatus status;

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    final String statusValue = (json['status'] as String? ?? 'sent').toLowerCase();
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String? ?? '',
      sentAt: DateTime.parse(json['created_at'] as String),
      isMine: json['sender_id'] == currentUserId,
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : null,
      status: MessageStatus.values.firstWhere(
        (MessageStatus item) => item.name == statusValue,
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'content': content,
      'created_at': sentAt.toIso8601String(),
      'image_urls': imageUrls,
      'status': status.name,
    };
  }
}
