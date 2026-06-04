import '../models/chat_message.dart';
import '../models/conversation_summary.dart';
import '../models/job_receipt_view.dart';
import '../models/user_profile_view.dart';

class SharedStubData {
  static const String currentUserId = '11111111-1111-4111-8111-111111111111';

  static final List<ConversationSummary> conversations = <ConversationSummary>[
    ConversationSummary(
      id: 'conv_1',
      jobId: '77777777-7777-4777-8777-777777777777',
      counterpartUserId: '22222222-2222-4222-8222-222222222222',
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
      jobId: '88888888-8888-4888-8888-888888888888',
      counterpartUserId: '33333333-3333-4333-8333-333333333333',
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
      jobId: '99999999-9999-4999-8999-999999999999',
      counterpartUserId: '44444444-4444-4444-8444-444444444444',
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
      jobId: 'AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA',
      counterpartUserId: '55555555-5555-4555-8555-555555555555',
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
      counterpartUserId: '66666666-6666-4666-8666-666666666666',
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
            senderId: '22222222-2222-4222-8222-222222222222',
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
            senderId: '22222222-2222-4222-8222-222222222222',
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
            senderId: '33333333-3333-4333-8333-333333333333',
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
            senderId: '44444444-4444-4444-8444-444444444444',
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
    id: '33333333-3333-4333-8333-333333333333',
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
    jobId: '77777777-7777-4777-8777-777777777777',
    title: 'Leaking kitchen sink',
    clientName: 'Ama Osei',
    location: 'Adum, Kumasi',
    completedAt: DateTime.now().subtract(const Duration(days: 2)),
    amountGhs: 180,
    status: 'Completed',
    notes: 'Replaced washer and checked under-sink trap.',
  );

  static const UserProfileViewData sampleWorkerProfile = UserProfileViewData(
    id: '22222222-2222-4222-8222-222222222222',
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
