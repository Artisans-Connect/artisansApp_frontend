import 'package:flutter/material.dart';

import 'package:artisans_app/core/navigation/app_routes.dart';
import 'package:artisans_app/features/client/presentation/client_shell.dart';
import 'package:artisans_app/features/worker/presentation/widgets/worker_bottom_nav.dart';
import 'package:artisans_app/core/session/app_user_session.dart';

/// Root navigation operations. Use these only when changing authenticated
/// context; tab changes should remain inside the active shell.
class AppNavigation {
  AppNavigation._();

  // Monotonic intent token prevents an older post-frame child push from
  // landing after a newer notification/deep-link reset has superseded it.
  static int _clientChildIntent = 0;

  static void resetToSignIn(BuildContext context, {String? initialEmail}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.authSignIn,
      (_) => false,
      arguments: initialEmail,
    );
  }

  static void resetToPasswordRecovery(
    BuildContext context, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.authForgotPassword,
      (_) => false,
      arguments: arguments,
    );
  }

  static void resetToRoleSelection(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.authRole, (_) => false);
  }

  static void resetToOnboarding(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.authOnboarding, (_) => false);
  }

  static void resetForMode(BuildContext context, String mode) {
    if (mode == 'worker' && AppUserSession.instance.isWorkerCapable) {
      resetToWorker(context);
    } else {
      resetToClient(context);
    }
  }

  /// Replaces the entire auth stack after a user has been restored or signed
  /// in. Keeping this decision here prevents individual auth screens from
  /// drifting on worker-capability or active-mode semantics.
  static void resetForUser(BuildContext context, AppUser user) {
    if (user.hasWorkerProfile && user.lastActiveMode == 'worker') {
      resetToWorker(context);
    } else {
      resetToClient(context);
    }
  }

  static void resetToClient(
    BuildContext context, {
    ClientNavTab initialTab = ClientNavTab.home,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.clientHome,
      (_) => false,
      arguments: <String, dynamic>{'initialTab': initialTab},
    );
  }

  static void resetToClientAndPush(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    if (!_clientChildRoutes.contains(routeName)) return;
    final int intent = ++_clientChildIntent;
    final navigator = Navigator.of(context);
    navigator.pushNamedAndRemoveUntil(
      AppRoutes.clientHome,
      (_) => false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigator.mounted && intent == _clientChildIntent) {
        navigator.pushNamed(routeName, arguments: arguments);
      }
    });
  }

  static void popToClientShellAndPush(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    if (!_clientChildRoutes.contains(routeName)) return;
    ++_clientChildIntent;
    Navigator.of(context).popUntil((route) =>
        route.settings.name == AppRoutes.clientHome ||
        route.settings.name == AppRoutes.clientHomeLegacy ||
        route.isFirst);
    Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  static const Set<String> _clientChildRoutes = <String>{
    AppRoutes.liveTracking,
    AppRoutes.jobApplicants,
  };

  static void resetToWorker(
    BuildContext context, {
    WorkerNavTab initialTab = WorkerNavTab.explore,
    String? openJobRequestId,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.workerHome,
      (_) => false,
      arguments: <String, dynamic>{
        'initialTab': initialTab.name,
        if (openJobRequestId != null) 'openJobRequestId': openJobRequestId,
      },
    );
  }
}
