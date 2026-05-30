import 'package:flutter/material.dart';

import '../../core/errors/error_messages.dart';
import '../../core/theme/app_colors.dart';

enum AppToastType { error, success, info }

/// Styled snackbars for consistent feedback across the app.
class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(_iconFor(type), color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _backgroundFor(type),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
        action: action,
      ),
    );
  }

  static void showError(BuildContext context, Object error, {String? fallback}) {
    show(
      context,
      message: userMessageFor(error, fallback: fallback),
      type: AppToastType.error,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.success);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.info);
  }

  static IconData _iconFor(AppToastType type) {
    switch (type) {
      case AppToastType.error:
        return Icons.error_outline_rounded;
      case AppToastType.success:
        return Icons.check_circle_outline_rounded;
      case AppToastType.info:
        return Icons.info_outline_rounded;
    }
  }

  static Color _backgroundFor(AppToastType type) {
    switch (type) {
      case AppToastType.error:
        return AppColors.error;
      case AppToastType.success:
        return const Color(0xFF15803D);
      case AppToastType.info:
        return AppColors.primary;
    }
  }
}
