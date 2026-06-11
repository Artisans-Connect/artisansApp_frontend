import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/utils/current_user.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../models/conversation_summary.dart';
import '../../widgets/conversation_tile.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/search_bar.dart';
import '../../utils/shared_user_context.dart';
import '../navigation/shared_route_args.dart';
import 'chat_detail_screen.dart';
import 'settings_screen.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({
    super.key,
    this.embedInShell = false,
    this.refreshSignal = 0,
  });

  static const String routeName = '/shared/messages';

  final bool embedInShell;
  final int refreshSignal;

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final ChatService _chatService = ChatService();
  bool _isLoading = true;
  String? _loadError;
  List<ConversationSummary> _conversations = <ConversationSummary>[];
  String _searchQuery = '';
  bool _openingSearch = false;

  bool get _isWorkerView => SharedUserContext.isViewingAsWorker;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void didUpdateWidget(covariant MessagesListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshSignal != oldWidget.refreshSignal) {
      _loadConversations(forceRefresh: true);
    }
  }

  Future<void> _loadConversations({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final dynamic response = await _chatService.getConversations(
        forceRefresh: forceRefresh,
        onRefreshed: (dynamic fresh) {
          if (!mounted) return;
          _applyConversationsResponse(fresh);
        },
      );
      if (!mounted) return;
      _applyConversationsResponse(response);
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = userMessageFor(e, fallback: 'Failed to load conversations.');
      });
    }
  }

  void _applyConversationsResponse(dynamic response) {
    final List<dynamic> data = response as List<dynamic>;
    final String currentUserId = CurrentUser.id ?? '';

    setState(() {
      _conversations = data.map((dynamic item) {
        final Map<String, dynamic> json = item as Map<String, dynamic>;
        final String clientId = json['client_id'] as String? ?? '';
        final String workerId = json['worker_id'] as String? ?? '';
        final bool isDirect = json['type'] == 'direct';
        final String counterpartId = json['counterpart_id'] as String? ??
            (clientId == currentUserId ? workerId : clientId);

        return ConversationSummary(
          id: json['id'] as String,
          jobId: isDirect ? null : json['id'] as String,
          counterpartUserId: counterpartId,
          counterpartName: json['counterpart_name'] as String? ?? 'User',
          counterpartAvatarUrl: json['counterpart_avatar_url'] as String?,
          lastMessagePreview: json['last_message_preview'] as String? ??
              json['title'] as String? ??
              'Open chat',
          lastMessageAt: DateTime.tryParse(
                json['last_message_at'] as String? ??
                    json['updated_at'] as String? ??
                    '',
              ) ??
              DateTime.now(),
          jobTitle: json['title'] as String?,
          isDirect: isDirect,
        );
      }).toList();
    });
  }

  List<ConversationSummary> get _filteredConversations {
    final String trimmedQuery = _searchQuery.trim();
    if (trimmedQuery.isEmpty) return _conversations;
    final String query = trimmedQuery.toLowerCase();
    return _conversations
        .where((ConversationSummary c) =>
            c.counterpartName.toLowerCase().contains(query) ||
            c.lastMessagePreview.toLowerCase().contains(query))
        .toList();
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
        isDirect: conversation.isDirect,
      ),
    );
  }

  void _openWorkerSearch() {
    if (_openingSearch) return;
    setState(() => _openingSearch = true);
    Navigator.pushNamed(
      context,
      AppRoutes.exploreArtisans,
      arguments: <String, dynamic>{'query': _searchQuery.trim()},
    ).whenComplete(() {
      if (mounted) setState(() => _openingSearch = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _isWorkerView
          ? null
          : FloatingActionButton(
              onPressed: _openingSearch ? null : _openWorkerSearch,
              backgroundColor: AppColors.primary,
              child: _openingSearch
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(PhosphorIcons.magnifyingGlass, color: Colors.white),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'Messages',
      showBackButton: !widget.embedInShell,
      actions: <Widget>[
        if (widget.embedInShell) ...[
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => _loadConversations(forceRefresh: true),
            icon: Icon(PhosphorIcons.arrowClockwise, color: AppColors.textPrimary),
          ),
        ] else ...[
          PopupMenuButton<String>(
            icon: Icon(PhosphorIcons.dotsThreeVertical, color: AppColors.textPrimary),
            onSelected: (String value) {
              if (value == 'settings') {
                Navigator.pushNamed(context, SettingsScreen.routeName);
              } else if (value == 'refresh') {
                _loadConversations(forceRefresh: true);
              }
            },
            itemBuilder: (_) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'refresh',
                child: Text('Refresh'),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
            ],
          ),
        ],
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildSkeletonList();
    }

    if (_loadError != null) {
      return ErrorStateView(
        message: _loadError!,
        title: 'Could not load messages',
        onRetry: () => _loadConversations(forceRefresh: true),
      );
    }

    return Column(
      children: <Widget>[
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: CustomSearchBar(
            hintText: 'Search conversations...',
            onChanged: (String value) => setState(() => _searchQuery = value),
          ),
        ),
        // Conversation list
        Expanded(
          child: _filteredConversations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => _loadConversations(forceRefresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _filteredConversations.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ConversationSummary conversation =
                          _filteredConversations[index];
                      return ConversationTile(
                        conversation: conversation,
                        onTap: () => _openChat(conversation),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(PhosphorIcons.chatCircle,
                size: 64, color: AppColors.outline),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: AppTypography.displayMedium.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _isWorkerView
                  ? 'Client conversations will appear here after a booking or enquiry starts.'
                  : 'When you match with an artisan or client, your chats will appear here.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge,
            ),
            if (!_isWorkerView) ...<Widget>[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _openingSearch ? null : _openWorkerSearch,
                icon: Icon(PhosphorIcons.magnifyingGlass),
                label: const Text('Find a worker'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: 5,
      itemBuilder: (_, int index) =>
          _ConversationSkeleton(key: ValueKey<int>(index)),
    );
  }
}

class _ConversationSkeleton extends StatelessWidget {
  const _ConversationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
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
                  const SizedBox(height: 10),
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
      ),
    );
  }
}
