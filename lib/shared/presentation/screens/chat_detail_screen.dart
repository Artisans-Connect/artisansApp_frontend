import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:artisans_app/core/errors/error_messages.dart';
import 'package:artisans_app/core/navigation/app_routes.dart';
import 'package:artisans_app/core/utils/current_user.dart';
import 'package:artisans_app/core/services/chat_service.dart';
import 'package:artisans_app/core/services/storage_service.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/shared/widgets/app_toast.dart';
import 'package:artisans_app/shared/widgets/error_state_view.dart';
import 'package:artisans_app/shared/models/picked_media.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/features/client/presentation/navigation/client_navigation.dart';
import 'package:artisans_app/shared/utils/shared_user_context.dart';
import 'package:artisans_app/shared/models/chat_message.dart';
import 'package:artisans_app/shared/widgets/chat_bubble.dart';
import 'package:artisans_app/shared/widgets/chat_composer.dart';
import 'package:artisans_app/shared/presentation/navigation/shared_route_args.dart';
import 'package:artisans_app/shared/presentation/screens/user_profile_screen.dart';
import 'package:artisans_app/shared/widgets/custom_back_button.dart';
import 'package:artisans_app/features/trust_safety/presentation/widgets/report_submission_bottom_sheet.dart';
import 'package:artisans_app/features/trust_safety/presentation/widgets/block_user_dialog.dart';
import 'package:artisans_app/features/trust_safety/services/reports_service.dart';

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
  bool _isLoading = false;
  bool _isSending = false;
  bool _isUploadingMedia = false;
  String? _loadError;
  RealtimeChannel? _realtimeChannel;
  Timer? _pollTimer;
  String? _activeConversationId;

  int _offset = 0;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  bool _isBlocked = false;
  bool _blockedByMe = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= 50 &&
        !_isFetchingMore &&
        _hasMore &&
        !_isLoading &&
        _activeConversationId != null) {
      _loadMoreMessages(_activeConversationId!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is ChatDetailArgs && _args == null) {
      _args = routeArgs;
      final String conversationId = routeArgs.isDirect
          ? routeArgs.conversationId
          : routeArgs.jobId ?? routeArgs.conversationId;
      if (!ClientNavigation.isValidJobChatId(conversationId)) {
        setState(() {
          _loadError =
              'Invalid conversation. Open chat from an active job or booking.';
        });
        return;
      }
      _activeConversationId = conversationId;
      _loadMessages(conversationId);
      _loadBlockStatus(routeArgs.counterpartUserId);
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
                  sentAt: DateTime.tryParse(
                          record['created_at'] as String? ?? '') ??
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

  Future<void> _loadBlockStatus(String counterpartUserId) async {
    final String targetId = counterpartUserId.trim();
    if (targetId.isEmpty || targetId == 'unknown') return;
    try {
      final Map<String, dynamic> status =
          await ReportsService.instance.checkBlockStatus(targetId);
      if (!mounted) return;
      setState(() {
        _isBlocked = status['is_blocked'] == true;
        _blockedByMe = status['is_blocked_by_me'] == true;
      });
    } catch (_) {
      // Fail open: on a lookup error leave the composer usable. The backend
      // still rejects blocked sends, so nothing gets through in error.
    }
  }

  Future<void> _loadMessages(String conversationId,
      {bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _loadError = null;
        _offset = 0;
        _hasMore = true;
      });
    }
    try {
      final dynamic response = await _chatService.getMessages(
        conversationId,
        limit: 30,
        offset: 0,
      );
      if (!mounted) return;

      final List<dynamic> data = response as List<dynamic>;
      setState(() {
        _messages = data.map((dynamic item) {
          final Map<String, dynamic> json = item as Map<String, dynamic>;
          return ChatMessage.fromJson(json, CurrentUser.id ?? '');
        }).toList();
        _isLoading = false;
        _offset = _messages.length;
        if (data.length < 30) {
          _hasMore = false;
        }
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

  Future<void> _loadMoreMessages(String conversationId) async {
    if (_isFetchingMore || !_hasMore) return;
    setState(() {
      _isFetchingMore = true;
    });
    try {
      final double previousMaxScroll = _scrollController.position.maxScrollExtent;

      final dynamic response = await _chatService.getMessages(
        conversationId,
        limit: 30,
        offset: _offset,
      );
      if (!mounted) return;

      final List<dynamic> data = response as List<dynamic>;
      final List<ChatMessage> olderMessages = data.map((dynamic item) {
        final Map<String, dynamic> json = item as Map<String, dynamic>;
        return ChatMessage.fromJson(json, CurrentUser.id ?? '');
      }).toList();

      setState(() {
        _messages.insertAll(0, olderMessages);
        _offset = _messages.length;
        _isFetchingMore = false;
        if (data.length < 30) {
          _hasMore = false;
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final double newMaxScroll = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(newMaxScroll - previousMaxScroll);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetchingMore = false;
      });
      AppToast.showError(context, e, fallback: 'Could not load older messages.');
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

  Future<void> _pickAndUploadAttachment(ImageSource source,
      {bool video = false}) async {
    if (_isUploadingMedia) return;

    try {
      setState(() => _isUploadingMedia = true);
      final XFile? file = video
          ? await _picker.pickVideo(
              source: source, maxDuration: const Duration(seconds: 60))
          : await _picker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;

      final PickedMedia media = await PickedMedia.fromXFile(file);
      final String? publicUrl =
          await StorageService.instance.uploadChatMedia(media);
      if (publicUrl == null) {
        if (!mounted) return;
        AppToast.showError(context, Exception('Media upload failed.'),
            fallback: 'Media upload failed.');
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
    if (_isBlocked) {
      AppToast.showInfo(
        context,
        _blockedByMe
            ? 'You blocked this user. Unblock from Settings to message again.'
            : "You can't message this user.",
      );
      return;
    }
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
        final int index =
            _messages.indexWhere((ChatMessage m) => m.id == tempId);
        if (index != -1) {
          _messages[index] = ChatMessage(
            id: json['id'] as String,
            senderId: json['sender_id'] as String,
            content: json['content'] as String? ?? '',
            sentAt: DateTime.tryParse(json['created_at'] as String) ??
                DateTime.now(),
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
        final int index =
            _messages.indexWhere((ChatMessage m) => m.id == tempId);
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
    if (SharedUserContext.isClient && args.counterpartUserId.isNotEmpty) {
      Navigator.pushNamed(
        context,
        AppRoutes.artisanProfile,
        arguments: <String, dynamic>{
          'id': args.counterpartUserId,
          'worker_id': args.counterpartUserId,
          'name': args.counterpartName,
          if ((args.counterpartPhone ?? '').trim().isNotEmpty)
            'phone': args.counterpartPhone,
        },
      );
      return;
    }
    Navigator.pushNamed(
      context,
      UserProfileScreen.routeName,
      arguments: ProfileArgs(
        userId: args.counterpartUserId,
        viewAsWorker: SharedUserContext.isClient,
      ),
    );
  }

  void _handleMoreAction(String action, ChatDetailArgs args) async {
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
      case 'report':
        ReportSubmissionBottomSheet.show(
          context,
          reportedId: args.counterpartUserId,
          reportedName: args.counterpartName,
          bookingId: args.jobId,
          chatId: args.conversationId,
        );
        break;
      case 'block':
        if (args.counterpartUserId.isEmpty) break;
        final bool blocked = await showBlockUserDialog(
          context,
          blockedId: args.counterpartUserId,
          displayName: args.counterpartName,
          source: 'chat',
        );
        if (blocked && mounted) {
          setState(() {
            _isBlocked = true;
            _blockedByMe = true;
          });
        }
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
                // Avatar
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
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        args.isDirect == true ? 'Direct enquiry' : 'Job chat',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
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
            icon: Icon(PhosphorIcons.dotsThreeVertical,
                color: AppColors.textPrimary),
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
              const PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.warningCircle, size: 18, color: Colors.orange),
                    SizedBox(width: 10),
                    Text('Report User'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'block',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.userMinus, size: 18, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Block User', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
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
                            padding:
                                const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            itemCount: _messages.length + 1 + (_isFetchingMore ? 1 : 0),
                            itemBuilder: (BuildContext context, int index) {
                              if (_isFetchingMore && index == 0) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.primary),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final int adjustedIndex = _isFetchingMore ? index - 1 : index;
                              if (adjustedIndex == 0) {
                                // Date separator
                                return Center(
                                  child: Container(
                                    margin:
                                        const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerHigh,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Today',
                                      style:
                                          AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return ChatBubble(
                                  message: _messages[adjustedIndex - 1]);
                            },
                          ),
          ),
          _isBlocked
              ? _buildBlockedBanner()
              : ChatComposer(
                  controller: _composerController,
                  isSending: _isSending,
                  isUploadingMedia: _isUploadingMedia,
                  onSend: _sendMessage,
                  onPickAttachment: (ImageSource source, bool video) =>
                      _pickAndUploadAttachment(source, video: video),
                ),
        ],
      ),
    );
  }

  Widget _buildBlockedBanner() {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Icon(PhosphorIcons.prohibit, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _blockedByMe
                    ? 'You blocked this user. Unblock them from Settings to message again.'
                    : "You can't message this user.",
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
