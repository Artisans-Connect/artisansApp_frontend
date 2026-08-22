import 'package:flutter/material.dart';

import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/shared/widgets/app_toast.dart';
import 'package:artisans_app/features/trust_safety/services/reports_service.dart';

/// Shared block-confirmation flow used by every surface that can block a user
/// (chat, profile, artisan profile, safety sheet) so the wording, the optional
/// reason capture and the success/error feedback stay identical everywhere.
///
/// Shows a confirmation dialog with an optional free-text reason, performs the
/// block through [ReportsService], and surfaces a success or error toast.
/// Returns `true` only when the user was successfully blocked, so callers can
/// update local state (e.g. flip a chat composer to a "blocked" banner).
///
/// [subjectLabel] tunes the copy for the person being blocked ("User",
/// "Worker", "Client"). [source] is folded into the stored reason when the user
/// doesn't type one, preserving the moderator context the old per-screen
/// hardcoded reasons used to carry.
Future<bool> showBlockUserDialog(
  BuildContext context, {
  required String blockedId,
  required String displayName,
  String subjectLabel = 'User',
  String source = 'app',
}) async {
  if (blockedId.isEmpty) return false;

  final TextEditingController reasonController = TextEditingController();

  try {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Block $displayName?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Blocking will prevent $displayName from contacting or booking '
                'with you, and hides you from each other. You can unblock them '
                'anytime from Settings.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                minLines: 1,
                maxLines: 3,
                maxLength: 200,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  hintText: 'Add a note for our safety team',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Block'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return false;

    final String typed = reasonController.text.trim();
    // Preserve the originating surface for moderator context even when the user
    // doesn't type anything (mirrors the previous per-screen hardcoded reasons).
    final String reason = typed.isNotEmpty ? typed : 'Blocked from $source';

    try {
      await ReportsService.instance.blockUser(
        blockedId: blockedId,
        reason: reason,
      );
      if (context.mounted) {
        AppToast.showSuccess(context, '$subjectLabel blocked.');
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(
          context,
          e,
          fallback: 'Could not block ${subjectLabel.toLowerCase()}.',
        );
      }
      return false;
    }
  } finally {
    reasonController.dispose();
  }
}
