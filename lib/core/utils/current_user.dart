import 'package:supabase_flutter/supabase_flutter.dart';

import '../session/app_user_session.dart';
import '../../shared/models/user_profile_view.dart';

/// Resolves the signed-in user's id and role from session (not stub data).
class CurrentUser {
  CurrentUser._();

  static String? get id =>
      AppUserSession.instance.currentUser?.id ??
      Supabase.instance.client.auth.currentUser?.id;

  static String? get email =>
      AppUserSession.instance.currentUser?.email ??
      Supabase.instance.client.auth.currentUser?.email;

  static UserRole? get role {
    final String? roleStr = AppUserSession.instance.currentUser?.role;
    if (roleStr == null) return null;
    if (roleStr == 'worker' || roleStr == 'artisan') return UserRole.worker;
    return UserRole.client;
  }

  static bool get isAuthenticated =>
      Supabase.instance.client.auth.currentSession != null;
}
