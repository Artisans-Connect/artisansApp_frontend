class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.counterpartUserId,
    required this.counterpartName,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    this.jobId,
    this.counterpartAvatarUrl,
    this.unreadCount = 0,
    this.jobTitle,
  });

  final String id;
  final String? jobId;
  final String counterpartUserId;
  final String counterpartName;
  final String? counterpartAvatarUrl;
  final String lastMessagePreview;
  final DateTime lastMessageAt;
  final int unreadCount;
  final String? jobTitle;
}
