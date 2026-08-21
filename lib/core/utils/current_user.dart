import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:artisans_app/core/session/app_user_session.dart';
import 'package:artisans_app/shared/models/user_profile_view.dart';

/// Resolves the signed-in user's id and active mode from session (not stub data).
class CurrentUser {
  CurrentUser._();

  static String? get id =>
      AppUserSession.instance.currentUser?.id ??
      _supabaseUserId;

  static String? get email =>
      AppUserSession.instance.currentUser?.email ??
      _supabaseEmail;

  static String get activeMode => AppUserSession.instance.activeMode;

  static bool get isWorkerCapable => AppUserSession.instance.isWorkerCapable;

  static UserRole? get role {
    final String mode = activeMode;
    if (mode == 'worker' || mode == 'artisan') return UserRole.worker;
    return UserRole.client;
  }

  static bool get isAuthenticated =>
      _hasSupabaseSession;

  static String? get _supabaseUserId {
    try {
      return Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  static String? get _supabaseEmail {
    try {
      return Supabase.instance.client.auth.currentUser?.email;
    } catch (_) {
      return null;
    }
  }

  static bool get _hasSupabaseSession {
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }
}
