import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/chat_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/current_user.dart';
import '../../../../shared/presentation/navigation/shared_route_args.dart';
import '../../../../shared/presentation/screens/chat_detail_screen.dart';
import '../../../../shared/presentation/screens/settings_screen.dart';
import '../../../../shared/presentation/screens/user_profile_screen.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/artisan_logo_avatar.dart';
import '../../../worker/presentation/worker_shell.dart';
import '../client_shell.dart';
import '../models/client_booking.dart';
import '../models/client_job_draft.dart';
import '../models/job_post_wizard_step.dart';
import 'client_shell_scope.dart';

/// Client-side navigation helpers (shell-safe).
class ClientNavigation {
  ClientNavigation._();

  static void selectTab(BuildContext context, ClientNavTab tab) {
    ClientShellScope.maybeOf(context)?.selectTab(tab);
  }

  static void popToShell(BuildContext context) {
    Navigator.popUntil(
      context,
      (Route<dynamic> route) =>
          route.settings.name == AppRoutes.clientHome ||
          route.settings.name == ClientShell.routeName ||
          route.isFirst,
    );
  }

  static void popToShellAndSelectTab(
    BuildContext context,
    ClientNavTab tab,
  ) {
    popToShell(context);
    selectTab(context, tab);
  }

  static Future<T?> pushFlow<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static final RegExp _jobIdPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static bool isValidJobChatId(String? id) =>
      id != null && id.isNotEmpty && _jobIdPattern.hasMatch(id);

  static void openChat(
    BuildContext context, {
    required String conversationId,
    required String counterpartUserId,
    required String counterpartName,
    String? jobId,
    String? jobTitle,
    bool isDirect = false,
    String? counterpartPhone,
  }) {
    final String effectiveJobId = jobId ?? conversationId;
    if (!isValidJobChatId(effectiveJobId)) {
      AppToast.showInfo(context, 'This conversation is not ready yet.');
      return;
    }
    Navigator.pushNamed(
      context,
      ChatDetailScreen.routeName,
      arguments: ChatDetailArgs(
        conversationId: conversationId,
        counterpartUserId: counterpartUserId,
        counterpartName: counterpartName,
        jobId: effectiveJobId,
        jobTitle: jobTitle,
        isDirect: isDirect,
        counterpartPhone: counterpartPhone,
      ),
    );
  }

  static Future<void> callPhone(BuildContext context, String phone) async {
    final String cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      AppToast.showInfo(context, 'This user has no phone number available.');
      return;
    }
    try {
      final bool launched = await launchUrl(Uri(scheme: 'tel', path: cleaned));
      if (!launched && context.mounted) {
        showPhoneDialog(context, phone);
      }
    } catch (_) {
      if (context.mounted) {
        showPhoneDialog(context, phone);
      }
    }
  }

  static void showPhoneDialog(BuildContext context, String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phone Contact'),
        content: SelectableText('Phone number: $phone'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void goToBookingsTab(BuildContext context) {
    popToShellAndSelectTab(context, ClientNavTab.bookings);
  }

  static void replaceWithBookingsTab(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.clientHome,
      (_) => false,
      arguments: <String, dynamic>{'initialTab': ClientNavTab.bookings},
    );
  }

  static void goToMessagesTab(BuildContext context) {
    popToShellAndSelectTab(context, ClientNavTab.messages);
  }

  static void openMessages(BuildContext context) {
    final ClientShellScope? scope = ClientShellScope.maybeOf(context);
    if (scope != null) {
      scope.selectTab(ClientNavTab.messages);
      return;
    }
    final String route = CurrentUser.role?.name == 'worker'
        ? WorkerShell.routeName
        : AppRoutes.clientHome;
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (_) => false,
      arguments: CurrentUser.role?.name == 'worker'
          ? <String, dynamic>{'initialTab': 'messages'}
          : <String, dynamic>{'initialTab': ClientNavTab.messages},
    );
  }

  static void openSettings(BuildContext context) {
    Navigator.pushNamed(context, SettingsScreen.routeName);
  }

  static void openOwnProfile(BuildContext context) {
    Navigator.pushNamed(
      context,
      UserProfileScreen.routeName,
      arguments: ProfileArgs(userId: CurrentUser.id ?? ''),
    );
  }

  static void openArtisanProfile(
    BuildContext context, {
    required String userId,
    String? name,
    Map<String, dynamic>? artisan,
  }) {
    Navigator.pushNamed(
      context,
      AppRoutes.artisanProfile,
      arguments: <String, dynamic>{
        if (artisan != null) ...artisan,
        'id': userId,
        'worker_id': userId,
        if (name != null) 'name': name,
      },
    );
  }

  static Future<void> openChatForArtisan(
    BuildContext context,
    Map<String, dynamic> artisan,
  ) async {
    final String? jobId =
        artisan['job_id'] as String? ?? artisan['jobId'] as String?;
    if (!isValidJobChatId(jobId)) {
      final Map<String, dynamic> profile = Map<String, dynamic>.from(
          artisan['profiles'] as Map<String, dynamic>? ??
              const <String, dynamic>{});
      final String workerId = (artisan['id'] ??
              artisan['worker_id'] ??
              artisan['userId'] ??
              profile['id'] ??
              '')
          .toString();
      final String name =
          (artisan['name'] ?? profile['full_name'] ?? 'Artisan').toString();
      final String? phone = (artisan['phone'] ?? profile['phone']) as String?;
      if (workerId.isEmpty || workerId == CurrentUser.id) {
        AppToast.showInfo(context, 'You cannot message this profile.');
        return;
      }
      try {
        final dynamic conversation =
            await ChatService().createDirectConversation(workerId);
        if (!context.mounted) return;
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(conversation as Map);
        openChat(
          context,
          conversationId: data['id'] as String,
          counterpartUserId: workerId,
          counterpartName: name,
          jobId: data['id'] as String,
          jobTitle: 'Enquiry',
          isDirect: true,
          counterpartPhone: phone,
        );
      } catch (_) {
        if (!context.mounted) return;
        AppToast.showError(
          context,
          Exception('Could not start this enquiry.'),
          fallback: 'Could not start this enquiry.',
        );
      }
      return;
    }
    final Map<String, dynamic> profile = Map<String, dynamic>.from(
        artisan['profiles'] as Map<String, dynamic>? ??
            const <String, dynamic>{});
    final String name =
        (artisan['name'] ?? profile['full_name'] ?? 'Artisan').toString();
    final String workerId = (artisan['id'] ??
            artisan['worker_id'] ??
            artisan['userId'] ??
            profile['id'] ??
            '')
        .toString();
    final String? phone = (artisan['phone'] ?? profile['phone']) as String?;
    openChat(
      context,
      conversationId: jobId!,
      counterpartUserId: workerId.isNotEmpty ? workerId : 'worker-unknown',
      counterpartName: name,
      jobId: jobId,
      jobTitle: (artisan['profession'] ??
              (artisan['skills'] is List &&
                      (artisan['skills'] as List).isNotEmpty
                  ? (artisan['skills'] as List).first.toString()
                  : null))
          .toString(),
      counterpartPhone: phone,
    );
  }

  /// After job post: open finding flow on top of current stack.
  static void startFindingArtisan(
    BuildContext context, {
    Map<String, dynamic>? jobData,
    Map<String, dynamic>? artisan,
  }) {
    pushFlow(
      context,
      AppRoutes.findingArtisan,
      arguments: <String, dynamic>{
        if (jobData != null) 'jobData': jobData,
        if (artisan != null) 'artisan': artisan,
      },
    );
  }

  /// After match: land on live tracking with wizard cleared back to shell.
  static void openLiveTrackingFromMatch(
    BuildContext context, {
    required Map<String, dynamic> booking,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.liveTracking,
      (Route<dynamic> route) => route.settings.name == ClientShell.routeName,
      arguments: booking,
    );
  }

  static void handleBookingTap(BuildContext context, ClientBooking booking) {
    if (booking.isLocalDraft) {
      openJobDraft(context, booking);
      return;
    }
    switch (booking.status) {
      case ClientBookingStatus.inProgress:
        pushFlow(context, AppRoutes.liveTracking, arguments: booking.toMap());
      case ClientBookingStatus.pendingApproval:
        pushFlow(context, AppRoutes.liveTracking, arguments: booking.toMap());
      case ClientBookingStatus.completed:
        if (booking.canRate) {
          pushFlow(context, AppRoutes.rateService, arguments: booking.toMap());
        } else {
          showBookingSummaryModal(context, booking);
        }
      case ClientBookingStatus.requested:
        if (booking.backendStatus == 'draft' &&
            booking.jobMode == 'scheduled') {
          AppToast.showInfo(
            context,
            'This scheduled job will start matching before the appointment.',
          );
        } else {
          pushFlow(context, AppRoutes.jobApplicants,
              arguments: booking.toMap());
        }
      case ClientBookingStatus.accepted:
        pushFlow(context, AppRoutes.liveTracking, arguments: booking.toMap());
      case ClientBookingStatus.cancelled:
        if (booking.isRecoverableServiceInterruption) {
          pushFlow(context, AppRoutes.liveTracking, arguments: booking.toMap());
        } else {
          showBookingSummaryModal(context, booking);
        }
      case ClientBookingStatus.draft:
        openJobDraft(context, booking);
    }
  }

  static void showBookingSummaryModal(
    BuildContext context,
    ClientBooking booking,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        final bool isCompleted =
            booking.status == ClientBookingStatus.completed;
        final bool isCancelled =
            booking.status == ClientBookingStatus.cancelled;
        final bool hasWorkerProfile = booking.counterpartUserId != null &&
            booking.counterpartUserId!.isNotEmpty;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIcons.x, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      booking.title,
                      style: AppTypography.displaySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFFF0FDF4)
                          : isCancelled
                              ? const Color(0xFFFEF2F2)
                              : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.status.displayLabel,
                      style: AppTypography.labelMedium.copyWith(
                        color: isCompleted
                            ? const Color(0xFF16A34A)
                            : isCancelled
                                ? const Color(0xFFDC2626)
                                : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: <Widget>[
                    ArtisanLogoAvatar(
                      imageUrl: booking.imageUrl,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            booking.artisan.isNotEmpty &&
                                    booking.artisan != 'Artisan'
                                ? booking.artisan
                                : 'Unmatched',
                            style: AppTypography.labelLarge,
                          ),
                          if (booking.profession.isNotEmpty &&
                              booking.profession != 'Artisan') ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              booking.profession,
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (booking.rating != null) ...<Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            PhosphorIcons.starFill,
                            size: 16,
                            color: Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.rating!.toStringAsFixed(1),
                            style: AppTypography.labelMedium,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  const Icon(PhosphorIcons.calendarBlank,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Date: ${booking.date.isNotEmpty ? booking.date : 'Recent'}',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
              if (booking.cancelledReason != null &&
                  booking.cancelledReason!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  'Cancellation Reason: ${booking.cancelledReason}',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (isCompleted && hasWorkerProfile) {
                      openArtisanProfile(
                        context,
                        userId: booking.counterpartUserId!,
                        name: booking.artisan,
                      );
                    } else if (isCancelled) {
                      pushFlow(context, AppRoutes.jobPostCategory);
                    }
                  },
                  child: Text(
                    isCompleted && hasWorkerProfile
                        ? 'Book Artisan Again'
                        : isCancelled
                            ? 'Post Similar Job'
                            : 'Done',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  static void openJobDraft(BuildContext context, ClientBooking booking) {
    final Map<String, dynamic> draftData =
        Map<String, dynamic>.from(booking.draftData ?? <String, dynamic>{});
    if (draftData.isEmpty) {
      pushFlow(context, AppRoutes.jobPostCategory);
      return;
    }

    final ClientJobDraft draft = ClientJobDraft.fromMap(draftData);
    final String routeName = _routeForDraft(draft);
    pushFlow(context, routeName, arguments: draft.toMap());
  }

  static String _routeForDraft(ClientJobDraft draft) {
    if (!draft.isValidForStep(JobPostWizardStep.category)) {
      return AppRoutes.jobPostCategory;
    }
    if (!draft.isValidForStep(JobPostWizardStep.subcategory)) {
      return AppRoutes.jobPostSubcategory;
    }
    if (!draft.isValidForStep(JobPostWizardStep.details)) {
      return AppRoutes.jobPostDetails;
    }
    if (!draft.isValidForStep(JobPostWizardStep.locationSchedule)) {
      return AppRoutes.jobPostLocationSchedule;
    }
    return AppRoutes.jobPostSummary;
  }
}
