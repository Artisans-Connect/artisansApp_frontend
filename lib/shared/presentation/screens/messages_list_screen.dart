import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../data/shared_stub_data.dart';
import '../../models/conversation_summary.dart';
import '../../widgets/conversation_tile.dart';
import '../navigation/shared_route_args.dart';
import 'chat_detail_screen.dart';
import 'settings_screen.dart';
import 'user_profile_screen.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key, this.embedInShell = false});

  static const String routeName = '/shared/messages';

  final bool embedInShell;

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  bool _isLoading = true;
  List<ConversationSummary> _conversations = <ConversationSummary>[];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _conversations = SharedStubData.conversations;
      _isLoading = false;
    });
  }

  void _openChat(ConversationSummary conversation) {
    Navigator.pushNamed(
      context,
      ChatDetailScreen.routeName,
      arguments: ChatDetailArgs(
        conversationId: conversation.id,
        jobId: conversation.jobId,
        counterpartUserId: conversation.counterpartUserId,
        counterpartName: conversation.counterpartName,
        jobTitle: conversation.jobTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Messages',
          style: AppTextStyles.displayMd.copyWith(fontSize: 22),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.primary),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.routeName),
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              UserProfileScreen.routeName,
              arguments:
                  const ProfileArgs(userId: SharedStubData.currentUserId),
            ),
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.surfaceDim,
              child: Icon(Icons.person, size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.only(top: 8),
        itemCount: 5,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: AppColors.outline.withOpacity(0.25),
        ),
        itemBuilder: (_, int index) =>
            _ConversationSkeleton(key: ValueKey<int>(index)),
      );
    }

    if (_conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.chat_bubble_outline,
                  size: 64, color: AppColors.outline),
              const SizedBox(height: 16),
              Text(
                'No conversations yet',
                style: AppTextStyles.displayMd.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'When you match with an artisan or client, your chats will appear here.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLg,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: _conversations.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: AppColors.outline.withOpacity(0.25),
        ),
        itemBuilder: (BuildContext context, int index) {
          final ConversationSummary conversation = _conversations[index];
          return ConversationTile(
            conversation: conversation,
            onTap: () => _openChat(conversation),
          );
        },
      ),
    );
  }
}

class _ConversationSkeleton extends StatelessWidget {
  const _ConversationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 180,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
