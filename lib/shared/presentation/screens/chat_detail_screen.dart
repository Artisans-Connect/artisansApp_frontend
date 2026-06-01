import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/utils/current_user.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/error_state_view.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/current_user.dart';
import '../../utils/shared_user_context.dart';
import '../../models/chat_message.dart';
import '../../widgets/chat_bubble.dart';
import '../../models/user_profile_view.dart';
import '../navigation/shared_route_args.dart';
import 'user_profile_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  static const String routeName = '/shared/chat';

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = <ChatMessage>[];
  ChatDetailArgs? _args;
  bool _showAttachmentMenu = false;
  bool _isLoading = false;
  String? _loadError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is ChatDetailArgs && _args == null) {
      _args = routeArgs;
      _loadMessages(routeArgs.jobId ?? routeArgs.conversationId);
    }
  }

  Future<void> _loadMessages(String jobId) async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final dynamic response = await _chatService.getMessages(jobId);
      if (!mounted) return;

      final List<dynamic> data = response as List<dynamic>;
      setState(() {
        _messages = data.map((dynamic item) {
          final Map<String, dynamic> json = item as Map<String, dynamic>;
          return ChatMessage(
            id: json['id'] as String,
            senderId: json['sender_id'] as String,
            content: json['content'] as String,
            sentAt: DateTime.tryParse(json['created_at'] as String) ?? DateTime.now(),
            isMine: json['sender_id'] == CurrentUser.id,
          );
        }).toList();
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = userMessageFor(e, fallback: 'Failed to load messages.');
      });
    }
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String text = _composerController.text.trim();
    if (text.isEmpty || _args == null) return;

    final String jobId = _args!.jobId ?? _args!.conversationId;
    final String tempId = 'local_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _messages.add(
        ChatMessage(
          id: tempId,
          senderId: CurrentUser.id ?? '',
          content: text,
          sentAt: DateTime.now(),
          isMine: true,
        ),
      );
      _composerController.clear();
    });
    _scrollToBottom();

    try {
      final dynamic response = await _chatService.sendMessage(jobId, text);
      final Map<String, dynamic> json = response as Map<String, dynamic>;
      
      setState(() {
        final int index = _messages.indexWhere((ChatMessage m) => m.id == tempId);
        if (index != -1) {
          _messages[index] = ChatMessage(
            id: json['id'] as String,
            senderId: json['sender_id'] as String,
            content: json['content'] as String,
            sentAt: DateTime.tryParse(json['created_at'] as String) ?? DateTime.now(),
            isMine: true,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((ChatMessage m) => m.id == tempId);
      });
      AppToast.showError(context, e, fallback: 'Failed to send message.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChatDetailArgs args = _args ??
        const ChatDetailArgs(
          conversationId: 'unknown',
          counterpartUserId: 'unknown',
          counterpartName: 'Chat',
        );

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 36,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: Icon(PhosphorIcons.arrowLeft(), color: AppColors.textPrimary),
          ),
        ),
        titleSpacing: 4,
        title: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            UserProfileScreen.routeName,
            arguments: ProfileArgs(
              userId: args.counterpartUserId,
              viewAsWorker: SharedUserContext.isClient,
            ),
          ),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: <Widget>[
                // Avatar with online dot
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.surfaceDim,
                        child: Text(
                          args.counterpartName.isNotEmpty
                              ? args.counterpartName[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.bodyLg.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        args.counterpartName,
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Online',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(PhosphorIcons.videoCamera(), color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(PhosphorIcons.dotsThreeVertical(), color: AppColors.textPrimary),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadError != null
                        ? ErrorStateView(
                            message: _loadError!,
                            title: 'Could not load chat',
                            compact: true,
                            onRetry: () => _loadMessages(
                              _args!.jobId ?? _args!.conversationId,
                            ),
                          )
                    : _messages.isEmpty
                        ? Center(
                            child: Text(
                              'Say hello to start the conversation.',
                              style: AppTextStyles.bodyLg,
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            itemCount: _messages.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                // Date separator
                                return Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Today',
                                      style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return ChatBubble(message: _messages[index - 1]);
                            },
                          ),
              ),
              _buildComposer(),
            ],
          ),
          if (_showAttachmentMenu)
            Positioned(
              bottom: 80,
              left: 16,
              child: _buildAttachmentMenu(),
            ),
        ],
      ),
    );
  }

  Widget _buildAttachmentMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: () => setState(() => _showAttachmentMenu = false),
            icon: Icon(PhosphorIcons.file(), color: AppColors.primary),
            tooltip: 'Document',
          ),
          IconButton(
            onPressed: () => setState(() => _showAttachmentMenu = false),
            icon: Icon(PhosphorIcons.camera(), color: AppColors.primary),
            tooltip: 'Camera',
          ),
          IconButton(
            onPressed: () => setState(() => _showAttachmentMenu = false),
            icon: Icon(PhosphorIcons.image(), color: AppColors.primary),
            tooltip: 'Gallery',
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: <Widget>[
          // Attachment button
          Material(
            color: AppColors.surfaceDim,
            borderRadius: BorderRadius.circular(99),
            child: InkWell(
              onTap: () {
                setState(() => _showAttachmentMenu = !_showAttachmentMenu);
              },
              borderRadius: BorderRadius.circular(99),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(PhosphorIcons.plus(), color: AppColors.textSecondary, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _composerController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.outline,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      PhosphorIcons.smiley(),
                      color: AppColors.outline,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(99),
            child: InkWell(
              onTap: _sendMessage,
              borderRadius: BorderRadius.circular(99),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(PhosphorIcons.paperPlaneRight(), color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
