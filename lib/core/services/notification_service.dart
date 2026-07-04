import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/worker/presentation/worker_shell.dart';
import '../navigation/app_routes.dart';
import '../network/api_client.dart';

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
  bool _pendingChatNavigate = false;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
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
      final token = await messaging.getToken();
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
        final token = await FirebaseMessaging.instance.getToken();
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
    if (_pendingChatNavigate) {
      _pendingChatNavigate = false;
      _openChat();
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
    final type = message.data['type'];
    final jobId = message.data['jobId'];
    
    if (type == 'new_job' && jobId is String && jobId.isNotEmpty) {
      if (navigatorKey.currentState == null) {
        _pendingJobRequestId = jobId;
        return;
      }
      _openWorkerRequest(jobId);
    } else if (type == 'chat_message') {
      _openChat();
    } else {
      // Client job updates
      final clientJobTypes = <String>[
        'worker_on_the_way',
        'worker_arrived',
        'job_started',
        'job_completion_submitted',
        'job_completed',
        'worker_cancelled_job',
        'client_cancelled_job',
        'job_cancelled',
        'job_expired',
        'termination_requested',
        'termination_resolved',
      ];
      if (clientJobTypes.contains(type) && jobId is String && jobId.isNotEmpty) {
        if (navigatorKey.currentState == null) {
          _pendingClientJobId = jobId;
          return;
        }
        _openClientJob(jobId);
      }
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

    navigator.pushNamedAndRemoveUntil(
      WorkerShell.routeName,
      (_) => false,
      arguments: <String, dynamic>{'openJobRequestId': jobId},
    );
  }

  void _openClientJob(String jobId) {
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
      AppRoutes.liveTracking,
      arguments: <String, dynamic>{'id': jobId},
    );
  }

  void _openChat() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingChatNavigate = true;
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      navigator.pushNamedAndRemoveUntil('/auth/sign-in', (_) => false);
      _pendingChatNavigate = true;
      return;
    }

    navigator.pushNamed('/shared/messages');
  }

  // ── Notification API methods ──────────────────────────────────────

  /// Fetches the current user's notifications from the backend.
  Future<List<dynamic>> getNotifications({int limit = 50}) async {
    final dynamic result = await _api.get('/notifications?limit=$limit');
    if (result is List) return result;
    return <dynamic>[];
  }

  /// Marks a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _api.patch('/notifications/$notificationId/read');
  }

  /// Marks all unread notifications as read.
  Future<void> markAllAsRead() async {
    await _api.patch('/notifications/read-all');
  }
}
