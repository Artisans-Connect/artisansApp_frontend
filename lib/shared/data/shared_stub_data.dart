import '../models/chat_message.dart';
import '../models/conversation_summary.dart';
import '../models/job_receipt_view.dart';
import '../models/user_profile_view.dart';

class SharedStubData {
  static const String currentUserId = 'user_me';

  static final List<ConversationSummary> conversations = <ConversationSummary>[
    ConversationSummary(
      id: 'conv_1',
      jobId: 'job_101',
      counterpartUserId: 'user_kwame',
      counterpartName: 'Kwame Mensah',
      lastMessagePreview: 'I can be there in 20 minutes.',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 12)),
      unreadCount: 2,
      jobTitle: 'Leaking kitchen sink',
    ),
    ConversationSummary(
      id: 'conv_2',
      jobId: 'job_102',
      counterpartUserId: 'user_ama',
      counterpartName: 'Ama Osei',
      lastMessagePreview: 'Thanks — job completed.',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 0,
      jobTitle: 'Electrical outlet repair',
    ),
    ConversationSummary(
      id: 'conv_3',
      jobId: 'job_103',
      counterpartUserId: 'user_kofi',
      counterpartName: 'Kofi Asante',
      lastMessagePreview: 'Sending photos of the damage now.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 1,
      jobTitle: 'Fence repair — Bantama',
    ),
  ];

  static List<ChatMessage> messagesForConversation(String conversationId) {
    switch (conversationId) {
      case 'conv_1':
        return <ChatMessage>[
          ChatMessage(
            id: 'm1',
            senderId: 'user_kwame',
            content: 'Hi, I saw your job request for the kitchen sink.',
            sentAt: DateTime.now().subtract(const Duration(hours: 1)),
            isMine: false,
          ),
          ChatMessage(
            id: 'm2',
            senderId: currentUserId,
            content: 'Great — are you available this afternoon?',
            sentAt: DateTime.now().subtract(const Duration(minutes: 45)),
            isMine: true,
          ),
          ChatMessage(
            id: 'm3',
            senderId: 'user_kwame',
            content: 'I can be there in 20 minutes.',
            sentAt: DateTime.now().subtract(const Duration(minutes: 12)),
            isMine: false,
          ),
        ];
      case 'conv_2':
        return <ChatMessage>[
          ChatMessage(
            id: 'm4',
            senderId: currentUserId,
            content: 'The outlet is fixed — thank you!',
            sentAt: DateTime.now().subtract(const Duration(hours: 4)),
            isMine: true,
          ),
          ChatMessage(
            id: 'm5',
            senderId: 'user_ama',
            content: 'Thanks — job completed.',
            sentAt: DateTime.now().subtract(const Duration(hours: 3)),
            isMine: false,
          ),
        ];
      default:
        return <ChatMessage>[
          ChatMessage(
            id: 'm6',
            senderId: 'user_kofi',
            content: 'Sending photos of the damage now.',
            sentAt: DateTime.now().subtract(const Duration(days: 1)),
            isMine: false,
          ),
        ];
    }
  }

  static ConversationSummary? conversationById(String id) {
    for (final ConversationSummary c in conversations) {
      if (c.id == id) return c;
    }
    return null;
  }

  static const UserProfileViewData currentUserProfile = UserProfileViewData(
    id: currentUserId,
    fullName: 'Kwabena Boateng',
    role: UserRole.client,
    phone: '+233 24 123 4567',
    locationLabel: 'Ahodwo, Kumasi',
    bio:
        'Homeowner in Kumasi — usually need urgent plumbing and electrical help.',
    rating: null,
    totalJobs: 4,
    isVerified: true,
  );

  static const UserProfileViewData sampleClientProfile = UserProfileViewData(
    id: 'user_ama',
    fullName: 'Ama Osei',
    role: UserRole.client,
    phone: '+233 20 555 1234',
    locationLabel: 'Bantama, Kumasi',
    bio: 'Frequently books electrical and plumbing jobs.',
    totalJobs: 12,
    isVerified: false,
  );

  static final JobReceiptViewData sampleJobReceipt = JobReceiptViewData(
    jobId: 'job_101',
    title: 'Leaking kitchen sink',
    clientName: 'Ama Osei',
    location: 'Adum, Kumasi',
    completedAt: DateTime.now().subtract(const Duration(days: 2)),
    amountGhs: 180,
    status: 'Completed',
    notes: 'Replaced washer and checked under-sink trap.',
  );

  static const UserProfileViewData sampleWorkerProfile = UserProfileViewData(
    id: 'user_kwame',
    fullName: 'Kwame Mensah',
    role: UserRole.worker,
    phone: '+233 55 987 6543',
    locationLabel: 'Suame, Kumasi',
    bio: 'Licensed plumber with 8 years experience across Kumasi.',
    rating: 4.8,
    totalJobs: 126,
    skills: <String>['Plumbing', 'Pipe fitting', 'Water heaters'],
    serviceAreas: <String>['Adum', 'Bantama', 'Suame'],
    experienceBand: '5+ years',
    isVerified: true,
  );
}
