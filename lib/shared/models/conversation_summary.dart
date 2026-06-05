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
    this.isOnline = false,
    this.isDirect = false,
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
  final bool isOnline;
  final bool isDirect;

  factory ConversationSummary.fromJson(Map<String, dynamic> json, String currentUserId) {
    // The backend returns participants and last_message
    final participants = json['participants'] as List<dynamic>? ?? [];
    final counterpart = participants.firstWhere(
      (p) => p['profile_id'] != currentUserId,
      orElse: () => <String, dynamic>{},
    );
    final lastMessage = json['last_message'] as Map<String, dynamic>?;

    return ConversationSummary(
      id: json['id'] as String,
      jobId: json['job_id'] as String?,
      counterpartUserId: counterpart['profile_id'] as String? ?? '',
      counterpartName: counterpart['full_name'] as String? ?? 'Unknown',
      counterpartAvatarUrl: counterpart['avatar_url'] as String?,
      lastMessagePreview: lastMessage?['content'] as String? ?? '',
      lastMessageAt: lastMessage != null 
          ? DateTime.parse(lastMessage['created_at'] as String) 
          : DateTime.parse(json['updated_at'] as String),
      unreadCount: json['unread_count'] as int? ?? 0,
      isDirect: json['type'] == 'direct',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'unread_count': unreadCount,
      // Full serialization is complex due to nested structure,
      // but usually we only need fromJson for fetching from the API.
    };
  }
}
