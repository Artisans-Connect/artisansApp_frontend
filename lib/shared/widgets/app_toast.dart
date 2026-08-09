import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/errors/error_messages.dart';

enum AppToastType { error, success, info, payment, escrow }

/// Premium styled toasts for payment, escrow, and transactional feedback across CraftMatch.
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

    final Color primaryColor = _backgroundFor(type);
    final Color badgeBg = _badgeColorFor(type);
    final IconData icon = _iconFor(type);

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
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

  static void showPayment(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.payment);
  }

  static void showEscrow(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.escrow);
  }

  static IconData _iconFor(AppToastType type) {
    switch (type) {
      case AppToastType.error:
        return PhosphorIcons.warningCircleBold;
      case AppToastType.success:
        return PhosphorIcons.checkCircleBold;
      case AppToastType.info:
        return PhosphorIcons.infoBold;
      case AppToastType.payment:
        return PhosphorIcons.walletBold;
      case AppToastType.escrow:
        return PhosphorIcons.shieldCheckBold;
    }
  }

  static Color _backgroundFor(AppToastType type) {
    switch (type) {
      case AppToastType.error:
        return const Color(0xFF991B1B); // Deep Crimson
      case AppToastType.success:
        return const Color(0xFF166534); // Forest Emerald
      case AppToastType.info:
        return const Color(0xFF1E293B); // Slate Dark
      case AppToastType.payment:
        return const Color(0xFF047857); // Mint Emerald
      case AppToastType.escrow:
        return const Color(0xFF0F766E); // Deep Escrow Teal
    }
  }

  static Color _badgeColorFor(AppToastType type) {
    switch (type) {
      case AppToastType.error:
        return Colors.white.withValues(alpha: 0.2);
      case AppToastType.success:
        return Colors.white.withValues(alpha: 0.2);
      case AppToastType.info:
        return Colors.white.withValues(alpha: 0.15);
      case AppToastType.payment:
        return const Color(0xFF059669);
      case AppToastType.escrow:
        return const Color(0xFF14B8A6);
    }
  }
}
