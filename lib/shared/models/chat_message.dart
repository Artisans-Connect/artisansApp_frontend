class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.isMine,
  });

  final String id;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isMine;
}
