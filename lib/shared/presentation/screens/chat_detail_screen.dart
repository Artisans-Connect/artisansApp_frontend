import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/utils/current_user.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/error_state_view.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/client/presentation/navigation/client_navigation.dart';
import '../../utils/shared_user_context.dart';
import '../../models/chat_message.dart';
import '../../widgets/chat_bubble.dart';
import '../navigation/shared_route_args.dart';
import 'user_profile_screen.dart';
import '../../widgets/custom_back_button.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  static const String routeName = '/shared/chat';

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = <ChatMessage>[];
  ChatDetailArgs? _args;
  bool _showAttachmentMenu = false;
  bool _isLoading = false;
  bool _isSending = false;
  bool _isUploadingMedia = false;
  String? _loadError;
  RealtimeChannel? _realtimeChannel;
  Timer? _pollTimer;
  String? _activeConversationId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is ChatDetailArgs && _args == null) {
      _args = routeArgs;
      final String conversationId =
          routeArgs.isDirect ? routeArgs.conversationId : routeArgs.jobId ?? routeArgs.conversationId;
      if (!ClientNavigation.isValidJobChatId(conversationId)) {
        setState(() {
          _loadError =
              'Invalid conversation. Open chat from an active job or booking.';
        });
        return;
      }
      _activeConversationId = conversationId;
      _loadMessages(conversationId);
      _subscribeToMessages(conversationId, isDirect: routeArgs.isDirect);
      _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (_activeConversationId != null) {
          _loadMessages(_activeConversationId!, silent: true);
        }
      });
    }
  }

  void _subscribeToMessages(String conversationId, {required bool isDirect}) {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = Supabase.instance.client
        .channel('chat-messages-$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: isDirect ? 'conversation_id' : 'job_id',
            value: conversationId,
          ),
          callback: (PostgresChangePayload payload) {
            final Map<String, dynamic> record = payload.newRecord;
            final String? id = record['id'] as String?;
            if (id == null || _messages.any((ChatMessage m) => m.id == id)) {
              return;
            }
            final String? senderId = record['sender_id'] as String?;
            if (senderId == CurrentUser.id) return;
            if (!mounted) return;
            setState(() {
              _messages.add(
                ChatMessage(
                  id: id,
                  senderId: senderId ?? '',
                  content: record['content'] as String? ?? '',
                  sentAt: DateTime.tryParse(record['created_at'] as String? ?? '') ??
                      DateTime.now(),
                  isMine: false,
                  imageUrls: (record['image_urls'] as List<dynamic>?)
                      ?.map((dynamic item) => item.toString())
                      .toList(),
                  mediaUrls: (record['media_urls'] as List<dynamic>?)
                      ?.map((dynamic item) => item.toString())
                      .toList(),
                  mediaTypes: (record['media_types'] as List<dynamic>?)
                      ?.map((dynamic item) => item.toString())
                      .toList(),
                  status: MessageStatus.sent,
                ),
              );
            });
            _scrollToBottom();
          },
        )
        .subscribe();
  }

  Future<void> _loadMessages(String conversationId, {bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final dynamic response = await _chatService.getMessages(conversationId);
      if (!mounted) return;

      final List<dynamic> data = response as List<dynamic>;
      setState(() {
        _messages = data.map((dynamic item) {
          final Map<String, dynamic> json = item as Map<String, dynamic>;
          return ChatMessage.fromJson(json, CurrentUser.id ?? '');
        }).toList();
        _isLoading = false;
      });
      if (!silent) _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      if (!silent) {
        setState(() {
          _isLoading = false;
          _loadError = userMessageFor(e, fallback: 'Failed to load messages.');
        });
      }
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
    _pollTimer?.cancel();
    _realtimeChannel?.unsubscribe();
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAttachment(ImageSource source, {bool video = false}) async {
    if (_isUploadingMedia) return;
    setState(() => _showAttachmentMenu = false);

    try {
      setState(() => _isUploadingMedia = true);
      final XFile? file = video
          ? await _picker.pickVideo(source: source, maxDuration: const Duration(seconds: 60))
          : await _picker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;

      final String? publicUrl = await StorageService.instance.uploadChatMedia(File(file.path));
      if (publicUrl == null) {
        if (!mounted) return;
        AppToast.showError(context, Exception('Media upload failed.'), fallback: 'Media upload failed.');
        return;
      }

      await _sendMessage(
        imageUrls: video ? null : <String>[publicUrl],
        mediaUrls: <String>[publicUrl],
        mediaTypes: <String>[video ? 'video' : 'image'],
      );
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Failed to upload media.');
    } finally {
      if (mounted) setState(() => _isUploadingMedia = false);
    }
  }

  Future<void> _sendMessage({
    List<String>? imageUrls,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
  }) async {
    if (_isSending) return;
    final String text = _composerController.text.trim();
    final bool hasMedia = (imageUrls != null && imageUrls.isNotEmpty) ||
        (mediaUrls != null && mediaUrls.isNotEmpty);
    if ((text.isEmpty && !hasMedia) || _args == null) return;

    final String conversationId =
        _activeConversationId ?? _args!.jobId ?? _args!.conversationId;
    if (!ClientNavigation.isValidJobChatId(conversationId)) {
      if (!mounted) return;
      AppToast.showError(
        context,
        Exception('No job linked to this chat.'),
        fallback: 'No job linked to this chat.',
      );
      return;
    }
    final String tempId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final String clientMessageId = const Uuid().v4();

    setState(() {
      _isSending = true;
      _messages.add(
        ChatMessage(
          id: tempId,
          senderId: CurrentUser.id ?? '',
          content: text,
          sentAt: DateTime.now(),
          isMine: true,
          imageUrls: imageUrls,
          mediaUrls: mediaUrls,
          mediaTypes: mediaTypes,
          status: MessageStatus.pending,
        ),
      );
      _composerController.clear();
    });
    _scrollToBottom();

    try {
      final dynamic response = await _chatService.sendMessage(
        conversationId,
        text,
        imageUrls: imageUrls,
        mediaUrls: mediaUrls,
        mediaTypes: mediaTypes,
        clientMessageId: clientMessageId,
      );
      final Map<String, dynamic> json = response as Map<String, dynamic>;
      
      setState(() {
        final int index = _messages.indexWhere((ChatMessage m) => m.id == tempId);
        if (index != -1) {
          _messages[index] = ChatMessage(
            id: json['id'] as String,
            senderId: json['sender_id'] as String,
            content: json['content'] as String? ?? '',
            sentAt: DateTime.tryParse(json['created_at'] as String) ?? DateTime.now(),
            isMine: true,
            imageUrls: (json['image_urls'] as List<dynamic>?)
                ?.map((dynamic item) => item.toString())
                .toList(),
            mediaUrls: (json['media_urls'] as List<dynamic>?)
                ?.map((dynamic item) => item.toString())
                .toList(),
            mediaTypes: (json['media_types'] as List<dynamic>?)
                ?.map((dynamic item) => item.toString())
                .toList(),
            status: MessageStatus.sent,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final int index = _messages.indexWhere((ChatMessage m) => m.id == tempId);
        if (index != -1) {
          _messages[index] = ChatMessage(
            id: tempId,
            senderId: CurrentUser.id ?? '',
            content: text,
            sentAt: _messages[index].sentAt,
            isMine: true,
            imageUrls: imageUrls,
            mediaUrls: mediaUrls,
            mediaTypes: mediaTypes,
            status: MessageStatus.failed,
          );
        }
      });
      AppToast.showError(context, e, fallback: 'Failed to send message.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _openProfile(ChatDetailArgs args) {
    Navigator.pushNamed(
      context,
      UserProfileScreen.routeName,
      arguments: ProfileArgs(
        userId: args.counterpartUserId,
        viewAsWorker: SharedUserContext.isClient,
      ),
    );
  }

  void _handleMoreAction(String action, ChatDetailArgs args) {
    switch (action) {
      case 'profile':
        _openProfile(args);
        break;
      case 'call':
        ClientNavigation.callPhone(context, args.counterpartPhone ?? '');
        break;
      case 'refresh':
        _loadMessages(
          _activeConversationId ?? args.jobId ?? args.conversationId,
        );
        break;
      case 'dismiss':
        setState(() => _showAttachmentMenu = false);
        break;
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
        leading: const CustomBackButton(),
        titleSpacing: 4,
        title: InkWell(
          onTap: () => _openProfile(args),
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
                          style: AppTypography.bodyLarge.copyWith(
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
                        style: AppTypography.bodyLarge.copyWith(
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
          PopupMenuButton<String>(
            icon: Icon(PhosphorIcons.dotsThreeVertical, color: AppColors.textPrimary),
            onSelected: (String action) => _handleMoreAction(action, args),
            itemBuilder: (_) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('View profile'),
              ),
              if ((args.counterpartPhone ?? '').trim().isNotEmpty)
                const PopupMenuItem<String>(
                  value: 'call',
                  child: Text('Call'),
                ),
              const PopupMenuItem<String>(
                value: 'refresh',
                child: Text('Refresh chat'),
              ),
              if (_showAttachmentMenu)
                const PopupMenuItem<String>(
                  value: 'dismiss',
                  child: Text('Close attachments'),
                ),
            ],
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
                              _activeConversationId ??
                                  _args!.jobId ??
                                  _args!.conversationId,
                            ),
                          )
                    : _messages.isEmpty
                        ? Center(
                            child: Text(
                              'Say hello to start the conversation.',
                              style: AppTypography.bodyLarge,
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
                                      style: AppTypography.bodyMedium.copyWith(
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: _isUploadingMedia
                ? null
                : () => _pickAndUploadAttachment(ImageSource.gallery, video: true),
            icon: Icon(PhosphorIcons.video, color: AppColors.primary),
            tooltip: 'Video',
          ),
          IconButton(
            onPressed: _isUploadingMedia
                ? null
                : () => _pickAndUploadAttachment(ImageSource.camera),
            icon: Icon(PhosphorIcons.camera, color: AppColors.primary),
            tooltip: 'Camera',
          ),
          IconButton(
            onPressed: _isUploadingMedia
                ? null
                : () => _pickAndUploadAttachment(ImageSource.gallery),
            icon: Icon(PhosphorIcons.image, color: AppColors.primary),
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
              onTap: _isUploadingMedia ? null : () {
                setState(() => _showAttachmentMenu = !_showAttachmentMenu);
              },
              borderRadius: BorderRadius.circular(99),
              child: Padding(padding: const EdgeInsets.all(10), child: Icon(PhosphorIcons.plus, color: AppColors.textSecondary, size: 22),
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
                        hintStyle: AppTypography.bodyMedium.copyWith(
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
                      PhosphorIcons.smiley,
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
              onTap: _isSending ? null : _sendMessage,
              borderRadius: BorderRadius.circular(99),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _isSending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(PhosphorIcons.paperPlaneRight, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
