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
      counterpartAvatarUrl: 'https://images.unsplash.com/photo-1506277886164-e25aa3f4ef7f?q=80&w=256&auto=format&fit=crop',
      lastMessagePreview: 'I can be there in 20 minutes.',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 2)),
      unreadCount: 2,
      jobTitle: 'Leaking kitchen sink',
      isOnline: true,
    ),
    ConversationSummary(
      id: 'conv_2',
      jobId: 'job_102',
      counterpartUserId: 'user_ama',
      counterpartName: 'Ama Osei',
      counterpartAvatarUrl: 'https://images.unsplash.com/photo-1531123897727-8f129e1bf98c?q=80&w=256&auto=format&fit=crop',
      lastMessagePreview: 'Thanks — job completed.',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      jobTitle: 'Electrical outlet repair',
      isOnline: false,
    ),
    ConversationSummary(
      id: 'conv_3',
      jobId: 'job_103',
      counterpartUserId: 'user_kofi',
      counterpartName: 'Kofi Asante',
      counterpartAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=256&auto=format&fit=crop',
      lastMessagePreview: 'Sending photos of the damage now.',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 1,
      jobTitle: 'Fence repair — Bantama',
      isOnline: true,
    ),
    ConversationSummary(
      id: 'conv_4',
      jobId: 'job_104',
      counterpartUserId: 'user_sasha',
      counterpartName: 'Sasha Ivanov',
      counterpartAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=256&auto=format&fit=crop',
      lastMessagePreview: 'The paint samples arrived this morning.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      jobTitle: 'Interior painting',
      isOnline: false,
    ),
    ConversationSummary(
      id: 'conv_5',
      counterpartUserId: 'user_david',
      counterpartName: 'David Brooks',
      counterpartAvatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=256&auto=format&fit=crop',
      lastMessagePreview: 'Is the site visit still confirmed for Tuesday?',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 0,
      isOnline: false,
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
            status: MessageStatus.sent,
          ),
          ChatMessage(
            id: 'm2',
            senderId: currentUserId,
            content: 'Great — are you available this afternoon?',
            sentAt: DateTime.now().subtract(const Duration(minutes: 45)),
            isMine: true,
            status: MessageStatus.sent,
          ),
          ChatMessage(
            id: 'm3',
            senderId: 'user_kwame',
            content: 'I can be there in 20 minutes.',
            sentAt: DateTime.now().subtract(const Duration(minutes: 12)),
            isMine: false,
            status: MessageStatus.sent,
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
            status: MessageStatus.sent,
          ),
          ChatMessage(
            id: 'm5',
            senderId: 'user_ama',
            content: 'Thanks — job completed.',
            sentAt: DateTime.now().subtract(const Duration(hours: 3)),
            isMine: false,
            status: MessageStatus.sent,
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
            status: MessageStatus.sent,
            imageUrls: const <String>[
              'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=600&auto=format&fit=crop',
            ],
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
    avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?q=80&w=256&auto=format&fit=crop',
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
    avatarUrl: 'https://images.unsplash.com/photo-1531123897727-8f129e1bf98c?q=80&w=256&auto=format&fit=crop',
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
    avatarUrl: 'https://images.unsplash.com/photo-1506277886164-e25aa3f4ef7f?q=80&w=256&auto=format&fit=crop',
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
