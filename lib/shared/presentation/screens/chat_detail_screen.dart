import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../data/shared_stub_data.dart';
import '../../models/chat_message.dart';
import '../../widgets/chat_bubble.dart';
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
      backgroundColor: const Color(0xFFF2F0F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        ),
        title: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            UserProfileScreen.routeName,
            arguments: ProfileArgs(
              userId: args.counterpartUserId,
              viewAsWorker: true,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                args.counterpartName,
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (args.jobTitle != null)
                Text(
                  args.jobTitle!,
                  style:
                      AppTextStyles.bodyMd.copyWith(color: AppColors.primary),
                ),
            ],
          ),
        ),
      ),
      body: Column(
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
                    itemCount: _messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ChatBubble(message: _messages[index]);
                    },
                  ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border(top: BorderSide(color: AppColors.outline.withOpacity(0.35))),
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
                filled: true,
                fillColor: AppColors.surfaceDim,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
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
