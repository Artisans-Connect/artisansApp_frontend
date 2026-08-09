import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/notifications/notification_metadata.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../models/notification_item.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/error_state_view.dart';

enum _NotificationFilter { all, unread, actionNeeded }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const String routeName = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService.instance;
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  String? _loadError;
  List<NotificationItem> _notifications = <NotificationItem>[];
  _NotificationFilter _filter = _NotificationFilter.all;

  int _offset = 0;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore &&
        _hasMore &&
        !_isLoading) {
      _loadMoreNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _offset = 0;
      _hasMore = true;
    });
    try {
      final List<dynamic> raw = await _notificationService.getNotifications(limit: 20, offset: 0);
      if (!mounted) return;
      setState(() {
        final List<NotificationItem> items = raw
            .whereType<Map<String, dynamic>>()
            .map(NotificationItem.fromJson)
            .toList();
        final Set<String> seen = <String>{};
        _notifications = items.where((NotificationItem n) => seen.add(n.id)).toList();
        
        _isLoading = false;
        _offset = _notifications.length;
        if (raw.length < 20) {
          _hasMore = false;
        }
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

  Future<void> _loadMoreNotifications() async {
    if (_isFetchingMore || !_hasMore) return;
    setState(() {
      _isFetchingMore = true;
    });
    try {
      final List<dynamic> raw = await _notificationService.getNotifications(
        limit: 20,
        offset: _offset,
      );
      if (!mounted) return;
      final List<NotificationItem> newItems = raw
          .whereType<Map<String, dynamic>>()
          .map(NotificationItem.fromJson)
          .toList();
      setState(() {
        final List<NotificationItem> combined = <NotificationItem>[..._notifications, ...newItems];
        final Set<String> seen = <String>{};
        _notifications = combined.where((NotificationItem n) => seen.add(n.id)).toList();
        
        _offset = _notifications.length;
        _isFetchingMore = false;
        if (raw.length < 20) {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetchingMore = false;
      });
      AppToast.showError(context, e, fallback: 'Could not load older notifications.');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      if (!mounted) return;
      final DateTime readAt = DateTime.now();
      setState(() {
        _notifications = _notifications
            .map(
              (NotificationItem n) => n.isRead
                  ? n
                  : NotificationItem(
                      id: n.id,
                      type: n.type,
                      title: n.title,
                      body: n.body,
                      data: n.data,
                      readAt: readAt,
                      createdAt: n.createdAt,
                    ),
            )
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
      final int index = _notifications
          .indexWhere((NotificationItem n) => n.id == notification.id);
      if (index == -1) return;
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
    } catch (_) {
      // Best effort; the next fetch will reconcile read state.
    }
  }

  void _onNotificationTap(NotificationItem notification) {
    _markAsRead(notification);
    final bool opened = _notificationService.openFromData(
      notification.data,
      fallbackType: notification.type,
    );
    if (!opened) {
      AppToast.showError(
        context,
        Exception('This update is missing job details.'),
        fallback: 'This update is missing job details.',
      );
    }
  }

  int get _unreadCount =>
      _notifications.where((NotificationItem n) => !n.isRead).length;

  int get _actionNeededCount =>
      _notifications.where(_isActionRequired).length;

  bool _isActionRequired(NotificationItem notification) {
    return NotificationMetadata.fromData(
      notification.data,
      fallbackType: notification.type,
    ).isActionRequired;
  }

  List<NotificationItem> get _visibleNotifications {
    switch (_filter) {
      case _NotificationFilter.unread:
        return _notifications
            .where((NotificationItem notification) => !notification.isRead)
            .toList();
      case _NotificationFilter.actionNeeded:
        return _notifications.where(_isActionRequired).toList();
      case _NotificationFilter.all:
        return _notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final String title =
        _unreadCount > 0 ? 'Notifications ($_unreadCount)' : 'Notifications';
    return CustomAppBar(
      title: title,
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

    final List<NotificationItem> visibleNotifications = _visibleNotifications;
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: visibleNotifications.isEmpty
            ? 2
            : visibleNotifications.length + 1 + (_hasMore ? 1 : 0),
        separatorBuilder: (_, int index) => index == 0
            ? const SizedBox.shrink()
            : Divider(
                height: 1,
                thickness: 0.5,
                indent: 72,
                endIndent: 16,
                color: AppColors.outlineVariant
                    .withAlpha((0.5 * 255).round()),
              ),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) return _buildFilterBar();
          if (visibleNotifications.isEmpty) return _buildFilteredEmptyState();
          if (index == visibleNotifications.length + 1) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            );
          }
          final NotificationItem notification = visibleNotifications[index - 1];
          return Dismissible(
            key: Key('notification_${notification.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: AppColors.error,
              child: Icon(
                PhosphorIcons.trash,
                color: Colors.white,
                size: 24,
              ),
            ),
            onDismissed: (DismissDirection direction) async {
              final String id = notification.id;
              setState(() {
                _notifications.removeWhere((NotificationItem n) => n.id == id);
              });
              try {
                await _notificationService.deleteNotification(id);
              } catch (e) {
                if (context.mounted) {
                  AppToast.showError(context, e, fallback: 'Could not delete notification.');
                  _loadNotifications();
                }
              }
            },
            child: _NotificationTile(
              notification: notification,
              onTap: () => _onNotificationTap(notification),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: <Widget>[
          _FilterChip(
            label: 'All',
            selected: _filter == _NotificationFilter.all,
            onTap: () => setState(() => _filter = _NotificationFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Unread',
            count: _unreadCount,
            selected: _filter == _NotificationFilter.unread,
            onTap: () => setState(() => _filter = _NotificationFilter.unread),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Action needed',
            count: _actionNeededCount,
            selected: _filter == _NotificationFilter.actionNeeded,
            onTap: () =>
                setState(() => _filter = _NotificationFilter.actionNeeded),
          ),
        ],
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
            Icon(
              PhosphorIcons.bellSlash,
              size: 64,
              color: AppColors.outline.withAlpha((0.4 * 255).round()),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: AppTypography.displayMedium.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You are all caught up. Job updates and messages will appear here.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    final String label = _filter == _NotificationFilter.unread
        ? 'No unread notifications'
        : 'No action needed';
    final String message = _filter == _NotificationFilter.unread
        ? 'Everything here has already been read.'
        : 'You do not have any notifications waiting for a response.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: Column(
        children: <Widget>[
          Icon(
            PhosphorIcons.bellSimple,
            size: 48,
            color: AppColors.outline.withAlpha((0.45 * 255).round()),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTypography.labelLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String text = count == null ? label : '$label $count';
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outlineVariant,
            ),
          ),
          child: Text(
            text,
            style: AppTypography.labelLarge.copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final NotificationItem notification;
  final VoidCallback onTap;

  NotificationMetadata get _metadata => NotificationMetadata.fromData(
        notification.data,
        fallbackType: notification.type,
      );

  IconData _iconForType(String type) {
    switch (type) {
      case 'chat_message':
        return PhosphorIcons.chatCircleText;
      case 'new_job':
        return PhosphorIcons.briefcase;
      case 'job_application_received':
      case 'job_application_accepted':
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

  Color _iconColorForMetadata(NotificationMetadata metadata) {
    if (metadata.priority == NotificationPriority.actionRequired) {
      return AppColors.primary;
    }
    switch (metadata.type) {
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
    final NotificationMetadata metadata = _metadata;
    final Color iconColor = _iconColorForMetadata(metadata);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread
            ? AppColors.primaryFixed.withAlpha((0.22 * 255).round())
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withAlpha((0.12 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForType(metadata.type),
                size: 22,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
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
                  if (metadata.jobTitle != null) ...<Widget>[
                    const SizedBox(height: 3),
                    Text(
                      metadata.jobTitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: iconColor.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          metadata.actionLabel,
                          style: AppTypography.bodySmall.copyWith(
                            color: iconColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (metadata.isActionRequired) ...<Widget>[
                        Text(
                          'Action needed',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
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
