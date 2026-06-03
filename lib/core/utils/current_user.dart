import 'package:supabase_flutter/supabase_flutter.dart';

import '../session/app_user_session.dart';
import '../../shared/models/user_profile_view.dart';

/// Resolves the signed-in user's id and active mode from session (not stub data).
class CurrentUser {
  CurrentUser._();

  static String? get id =>
      AppUserSession.instance.currentUser?.id ??
      Supabase.instance.client.auth.currentUser?.id;

  static String? get email =>
      AppUserSession.instance.currentUser?.email ??
      Supabase.instance.client.auth.currentUser?.email;

  static String get activeMode => AppUserSession.instance.activeMode;

  static bool get isWorkerCapable => AppUserSession.instance.isWorkerCapable;

  static UserRole? get role {
    final String mode = activeMode;
    if (mode == 'worker' || mode == 'artisan') return UserRole.worker;
    return UserRole.client;
  }

  static bool get isAuthenticated =>
      Supabase.instance.client.auth.currentSession != null;
}
