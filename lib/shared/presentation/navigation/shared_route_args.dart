class ChatDetailArgs {
  const ChatDetailArgs({
    required this.conversationId,
    required this.counterpartUserId,
    required this.counterpartName,
    this.jobId,
    this.jobTitle,
  });

  final String conversationId;
  final String? jobId;
  final String counterpartUserId;
  final String counterpartName;
  final String? jobTitle;
}

class ProfileArgs {
  const ProfileArgs({
    required this.userId,
    this.viewAsWorker = false,
    this.profileData,
  });

  final String userId;
  final bool viewAsWorker;
  final Map<String, dynamic>? profileData;
}
