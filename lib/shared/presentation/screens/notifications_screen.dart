import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../models/notification_item.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/app_toast.dart';
import '../navigation/shared_route_args.dart';
import 'chat_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  static const String routeName = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService.instance;

  bool _isLoading = true;
  String? _loadError;
  List<NotificationItem> _notifications = <NotificationItem>[];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final List<dynamic> raw = await _notificationService.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = raw
            .whereType<Map<String, dynamic>>()
            .map((Map<String, dynamic> json) => NotificationItem.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError =
            userMessageFor(e, fallback: 'Failed to load notifications.');
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      if (!mounted) return;
      setState(() {
        _notifications = _notifications
            .map((NotificationItem n) => n.isRead
                ? n
                : NotificationItem(
                    id: n.id,
                    type: n.type,
                    title: n.title,
                    body: n.body,
                    data: n.data,
                    readAt: DateTime.now(),
                    createdAt: n.createdAt,
                  ))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        e,
        fallback: 'Could not mark notifications as read.',
      );
    }
  }

  Future<void> _markAsRead(NotificationItem notification) async {
    if (notification.isRead) return;
    try {
      await _notificationService.markAsRead(notification.id);
      if (!mounted) return;
      final int index =
          _notifications.indexWhere((NotificationItem n) => n.id == notification.id);
      if (index != -1) {
        setState(() {
          _notifications[index] = NotificationItem(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            body: notification.body,
            data: notification.data,
            readAt: DateTime.now(),
            createdAt: notification.createdAt,
          );
        });
      }
    } catch (_) {
      // Silently fail; notification will be marked on next fetch.
    }
  }

  void _onNotificationTap(NotificationItem notification) {
    _markAsRead(notification);
    _routeToDestination(notification);
  }

  void _routeToDestination(NotificationItem notification) {
    final String type = notification.type;
    final String? jobId = notification.data?['jobId'] as String?;

    if (type == 'chat_message' && jobId != null) {
      Navigator.pushNamed(
        context,
        ChatDetailScreen.routeName,
        arguments: ChatDetailArgs(
          conversationId: jobId,
          jobId: jobId,
          counterpartUserId: '',
          counterpartName: 'Chat',
        ),
      );
    }
    // Other notification types stay on the screen (already read).
  }

  int get _unreadCount =>
      _notifications.where((NotificationItem n) => !n.isRead).length;

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'Notifications',
      actions: <Widget>[
        if (_unreadCount > 0)
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              'Read all',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildSkeletonList();

    if (_loadError != null) {
      return ErrorStateView(
        title: 'Could not load notifications',
        message: _loadError!,
        onRetry: _loadNotifications,
      );
    }

    if (_notifications.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 0.5,
          indent: 72,
          endIndent: 16,
          color: AppColors.outlineVariant.withAlpha((0.5 * 255).round()),
        ),
        itemBuilder: (BuildContext context, int index) {
          return _NotificationTile(
            notification: _notifications[index],
            onTap: () => _onNotificationTap(_notifications[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(PhosphorIcons.bellSlash,
                size: 64, color: AppColors.outline.withAlpha((0.4 * 255).round())),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: AppTypography.displayMedium.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up! Check back later.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12),
      itemCount: 6,
      itemBuilder: (_, int index) =>
          _NotificationSkeleton(key: ValueKey<int>(index)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Notification Tile
// ═══════════════════════════════════════════════════════════════════════

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final NotificationItem notification;
  final VoidCallback onTap;

  IconData _iconForType(String type) {
    switch (type) {
      case 'chat_message':
        return PhosphorIcons.chatCircleText;
      case 'new_job':
        return PhosphorIcons.briefcase;
      case 'job_matched':
        return PhosphorIcons.handshake;
      case 'job_started':
        return PhosphorIcons.play;
      case 'job_completed':
      case 'job_completion_submitted':
        return PhosphorIcons.checkCircle;
      case 'job_cancelled':
      case 'worker_cancelled_job':
      case 'client_cancelled_job':
        return PhosphorIcons.xCircle;
      case 'worker_on_the_way':
        return PhosphorIcons.mapPin;
      case 'worker_arrived':
        return PhosphorIcons.mapPinArea;
      case 'scheduled_reminder':
        return PhosphorIcons.calendarCheck;
      case 'job_expired':
        return PhosphorIcons.clockCountdown;
      case 'termination_requested':
      case 'termination_resolved':
        return PhosphorIcons.warning;
      default:
        return PhosphorIcons.bell;
    }
  }

  Color _iconColorForType(String type) {
    switch (type) {
      case 'job_completed':
      case 'job_completion_submitted':
      case 'job_matched':
        return AppColors.success;
      case 'job_cancelled':
      case 'worker_cancelled_job':
      case 'client_cancelled_job':
      case 'job_expired':
      case 'termination_requested':
        return AppColors.error;
      case 'chat_message':
        return AppColors.accentBlue;
      case 'new_job':
      case 'scheduled_reminder':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  String _timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool unread = !notification.isRead;
    final Color iconColor = _iconColorForType(notification.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread
            ? AppColors.primaryFixed.withAlpha((0.25 * 255).round())
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withAlpha((0.12 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForType(notification.type),
                size: 22,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight:
                                unread ? FontWeight.w700 : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeAgo(notification.createdAt),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.outline,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: AppTypography.bodyMedium.copyWith(
                      color: unread
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Unread dot
            if (unread)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Skeleton shimmer placeholder
// ═══════════════════════════════════════════════════════════════════════

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.surfaceDim,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(6),
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
