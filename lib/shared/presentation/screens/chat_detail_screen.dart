import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../data/shared_stub_data.dart';
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
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = <ChatMessage>[];
  ChatDetailArgs? _args;
  bool _showAttachmentMenu = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is ChatDetailArgs && _args == null) {
      _args = routeArgs;
      _messages = List<ChatMessage>.from(
        SharedStubData.messagesForConversation(routeArgs.conversationId),
      );
    }
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final String text = _composerController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          senderId: SharedStubData.currentUserId,
          content: text,
          sentAt: DateTime.now(),
          isMine: true,
        ),
      );
      _composerController.clear();
    });

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
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
        titleSpacing: 4,
        title: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            UserProfileScreen.routeName,
            arguments: ProfileArgs(
              userId: args.counterpartUserId,
              viewAsWorker: SharedStubData.currentUserProfile.role == UserRole.client,
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
            icon: const Icon(Icons.videocam_outlined, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: _messages.isEmpty
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
            icon: const Icon(Icons.insert_drive_file_outlined, color: AppColors.primary),
            tooltip: 'Document',
          ),
          IconButton(
            onPressed: () => setState(() => _showAttachmentMenu = false),
            icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
            tooltip: 'Camera',
          ),
          IconButton(
            onPressed: () => setState(() => _showAttachmentMenu = false),
            icon: const Icon(Icons.image_outlined, color: AppColors.primary),
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
                child: Icon(Icons.add, color: AppColors.textSecondary, size: 22),
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
                      Icons.emoji_emotions_outlined,
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
                child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
