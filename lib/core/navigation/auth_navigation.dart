import '../../features/client/presentation/client_shell.dart';
import '../../features/worker/presentation/worker_shell.dart';
import '../session/app_user_session.dart';

/// Routes to the correct shell based on capabilities and last active mode.
String shellRouteForUser(AppUser user) {
  if (user.hasWorkerProfile && user.lastActiveMode == 'worker') {
    return WorkerShell.routeName;
  }
  return ClientShell.routeName;
}

String shellRouteForMode(String mode, bool hasWorkerProfile) {
  if (hasWorkerProfile && mode == 'worker') {
    return WorkerShell.routeName;
  }
  return ClientShell.routeName;
}

/// @deprecated Use [shellRouteForUser] or [shellRouteForMode].
String shellRouteForRole(String? role) {
  return shellRouteForMode(role ?? 'client', role == 'worker' || role == 'artisan');
}

bool isWorkerRole(String? role) {
  final String normalized = (role ?? '').toLowerCase();
  return normalized == 'worker' || normalized == 'artisan';
}
