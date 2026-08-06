import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/worker/presentation/worker_shell.dart';
import '../constants/app_constants.dart';
import '../navigation/app_routes.dart';
import '../network/api_client.dart';
import '../notifications/notification_metadata.dart';
import '../../shared/presentation/navigation/shared_route_args.dart';
import '../../shared/presentation/screens/chat_detail_screen.dart';
import '../session/app_user_session.dart';
import 'auth_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final ApiClient _api = ApiClient.instance;

  StreamSubscription<String>? _tokenRefreshSub;
  String? _lastTokenHash;
  String? _pendingJobRequestId;
  String? _pendingClientJobId;
  String? _pendingClientApplicantsJobId;
  String? _pendingChatJobId;
  bool _pendingWorkerBookings = false;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _handleMessageTap(initial);
    } catch (_) {
      // Firebase config can be absent in local/dev builds.
    }
  }

  Future<void> registerCurrentDevice() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = kIsWeb && AppConstants.firebaseVapidKey.isNotEmpty
          ? await messaging.getToken(vapidKey: AppConstants.firebaseVapidKey)
          : await messaging.getToken();
      if (token == null || token.isEmpty) return;

      await _registerToken(token);
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = messaging.onTokenRefresh.listen((token) {
        unawaited(_registerToken(token));
      });
    } catch (_) {
      // Push is best-effort; in-app realtime still works.
    }
  }

  Future<void> unregisterCurrentDevice() async {
    String? tokenHash = _lastTokenHash;
    if (tokenHash == null) {
      try {
        final messaging = FirebaseMessaging.instance;
        final token = kIsWeb && AppConstants.firebaseVapidKey.isNotEmpty
            ? await messaging.getToken(vapidKey: AppConstants.firebaseVapidKey)
            : await messaging.getToken();
        if (token != null && token.isNotEmpty) {
          tokenHash = _hashToken(token);
        }
      } catch (_) {
        // Firebase may be unavailable in local builds.
      }
    }
    if (tokenHash == null) return;
    try {
      await _api.delete('/profiles/me/notification-devices/$tokenHash');
    } catch (_) {
      // Logout must not be blocked by push cleanup.
    } finally {
      _lastTokenHash = null;
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = null;
    }
  }

  void drainPendingNavigation() {
    final workerJobId = _pendingJobRequestId;
    if (workerJobId != null) {
      _pendingJobRequestId = null;
      _openWorkerRequest(workerJobId);
      return;
    }
    final clientJobId = _pendingClientJobId;
    if (clientJobId != null) {
      _pendingClientJobId = null;
      _openClientJob(clientJobId);
      return;
    }
    final applicantsJobId = _pendingClientApplicantsJobId;
    if (applicantsJobId != null) {
      _pendingClientApplicantsJobId = null;
      _openClientApplicants(applicantsJobId);
      return;
    }
    final chatJobId = _pendingChatJobId;
    if (chatJobId != null) {
      _pendingChatJobId = null;
      _openChat(chatJobId);
      return;
    }
    if (_pendingWorkerBookings) {
      _pendingWorkerBookings = false;
      _openWorkerBookings();
    }
  }

  Future<void> _registerToken(String token) async {
    final tokenHash = _hashToken(token);
    await _api.post(
      '/profiles/me/notification-devices',
      body: <String, dynamic>{
        'fcm_token': token,
        'platform': _platformName(),
      },
    );
    _lastTokenHash = tokenHash;
  }

  String _hashToken(String token) =>
      sha256.convert(utf8.encode(token)).toString();

  String _platformName() {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name.toLowerCase();
  }

  void _handleMessageTap(RemoteMessage message) {
    openFromData(message.data);
  }

  bool openFromData(Map<String, dynamic>? data, {String fallbackType = 'general'}) {
    final metadata =
        NotificationMetadata.fromData(data, fallbackType: fallbackType);
    final String? jobId = metadata.jobId;

    switch (metadata.route) {
      case NotificationRouteTarget.workerJobRequest:
        if (jobId == null) return false;
        _openWorkerRequest(jobId);
        return true;
      case NotificationRouteTarget.workerActiveBooking:
        _openWorkerBookings();
        return true;
      case NotificationRouteTarget.clientJobApplicants:
        if (jobId == null) return false;
        _openClientApplicants(jobId);
        return true;
      case NotificationRouteTarget.clientLiveTracking:
        if (jobId == null) return false;
        _openClientJob(jobId);
        return true;
      case NotificationRouteTarget.chatDetail:
        if (jobId == null) {
          _openMessages();
          return true;
        }
        _openChat(jobId);
        return true;
      case NotificationRouteTarget.notifications:
        _openNotifications();
        return true;
    }
  }

  void _openWorkerRequest(String jobId) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingJobRequestId = jobId;
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      navigator.pushNamedAndRemoveUntil('/auth/sign-in', (_) => false);
      _pendingJobRequestId = jobId;
      return;
    }

    unawaited(AuthService.instance
        .updateActiveMode('worker')
        .catchError((_) => AppUserSession.instance.updateActiveMode('worker')));

    navigator.pushNamedAndRemoveUntil(
      WorkerShell.routeName,
      (_) => false,
      arguments: <String, dynamic>{'openJobRequestId': jobId},
    );
  }

  void _openClientJob(String jobId) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingClientApplicantsJobId = jobId;
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      navigator.pushNamedAndRemoveUntil('/auth/sign-in', (_) => false);
      _pendingClientApplicantsJobId = jobId;
      return;
    }

    navigator.pushNamed(
      AppRoutes.liveTracking,
      arguments: <String, dynamic>{'id': jobId},
    );
  }

  void _openClientApplicants(String jobId) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingClientJobId = jobId;
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      navigator.pushNamedAndRemoveUntil('/auth/sign-in', (_) => false);
      _pendingClientJobId = jobId;
      return;
    }

    navigator.pushNamed(
      AppRoutes.jobApplicants,
      arguments: <String, dynamic>{'id': jobId, 'job_id': jobId},
    );
  }

  void _openWorkerBookings() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingWorkerBookings = true;
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      navigator.pushNamedAndRemoveUntil('/auth/sign-in', (_) => false);
      _pendingWorkerBookings = true;
      return;
    }

    unawaited(AuthService.instance
        .updateActiveMode('worker')
        .catchError((_) => AppUserSession.instance.updateActiveMode('worker')));

    navigator.pushNamedAndRemoveUntil(
      WorkerShell.routeName,
      (_) => false,
      arguments: <String, dynamic>{'initialTab': 'bookings'},
    );
  }

  void _openMessages() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushNamed('/shared/messages');
  }

  void _openChat(String jobId) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingChatJobId = jobId;
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      navigator.pushNamedAndRemoveUntil('/auth/sign-in', (_) => false);
      _pendingChatJobId = jobId;
      return;
    }

    navigator.pushNamed(
      ChatDetailScreen.routeName,
      arguments: ChatDetailArgs(
        conversationId: jobId,
        jobId: jobId,
        counterpartUserId: '',
        counterpartName: 'Chat',
      ),
    );
  }

  void _openNotifications() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushNamed(AppRoutes.notifications);
  }

  // ── Notification API methods ──────────────────────────────────────

  /// Fetches the current user's notifications from the backend.
  Future<List<dynamic>> getNotifications({int limit = 20, int offset = 0}) async {
    final dynamic result =
        await _api.get('/notifications?limit=$limit&offset=$offset');
    if (result is List) return result;
    return <dynamic>[];
  }

  Future<int> getUnreadCount() async {
    final dynamic result = await _api.get('/notifications/unread-count');
    if (result is Map<String, dynamic>) {
      final dynamic count = result['unread_count'];
      if (count is int) return count;
      if (count is num) return count.toInt();
    }
    return 0;
  }

  /// Marks a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _api.patch('/notifications/$notificationId/read');
  }

  /// Marks all unread notifications as read.
  Future<void> markAllAsRead() async {
    await _api.patch('/notifications/read-all');
  }

  /// Deletes a single notification.
  Future<void> deleteNotification(String notificationId) async {
    await _api.delete('/notifications/$notificationId');
  }
}
