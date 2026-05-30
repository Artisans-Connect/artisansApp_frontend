import '../../features/client/presentation/client_shell.dart';
import '../../features/worker/presentation/worker_shell.dart';

/// Normalizes backend/client role strings to the correct app shell route.
String shellRouteForRole(String? role) {
  final String normalized = (role ?? 'client').toLowerCase();
  if (normalized == 'worker' || normalized == 'artisan') {
    return WorkerShell.routeName;
  }
  return ClientShell.routeName;
}

bool isWorkerRole(String? role) {
  final String normalized = (role ?? '').toLowerCase();
  return normalized == 'worker' || normalized == 'artisan';
}
