import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:artisans_app/core/navigation/app_routes.dart';
import 'package:artisans_app/core/services/chat_service.dart';
import 'package:artisans_app/core/utils/current_user.dart';
import 'package:artisans_app/shared/presentation/navigation/shared_route_args.dart';
import 'package:artisans_app/shared/presentation/screens/chat_detail_screen.dart';
import 'package:artisans_app/shared/presentation/screens/settings_screen.dart';
import 'package:artisans_app/shared/presentation/screens/user_profile_screen.dart';
import 'package:artisans_app/shared/widgets/app_toast.dart';
import 'package:artisans_app/features/worker/presentation/worker_shell.dart';
import 'package:artisans_app/features/client/presentation/client_shell.dart';
import 'package:artisans_app/features/client/presentation/models/client_booking.dart';
import 'package:artisans_app/features/client/presentation/models/client_job_draft.dart';
import 'package:artisans_app/features/client/presentation/models/job_post_wizard_step.dart';
import 'package:artisans_app/features/client/presentation/navigation/client_shell_scope.dart';
import 'package:artisans_app/features/client/presentation/screens/payment_checkout_screen.dart';
import 'package:artisans_app/features/client/presentation/widgets/booking_summary_sheet.dart';

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
    final ClientShellScope? scope = ClientShellScope.maybeOf(context);
    popToShell(context);
    scope?.selectTab(tab);
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

  static void goToBookingHistory(BuildContext context) {
    goToBookingsTab(context);
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

  static Future<void> handleBookingTap(BuildContext context, ClientBooking booking) async {
    if (booking.isLocalDraft) {
      openJobDraft(context, booking);
      return;
    }
    switch (booking.status) {
      case ClientBookingStatus.inProgress:
        await pushFlow(context, AppRoutes.liveTracking, arguments: booking.toMap());
      case ClientBookingStatus.pendingApproval:
        await pushFlow(context, AppRoutes.liveTracking, arguments: booking.toMap());
      case ClientBookingStatus.completed:
        if (booking.canRate) {
          await pushFlow(context, AppRoutes.rateService, arguments: booking.toMap());
        } else {
          showBookingSummaryModal(context, booking);
        }
      case ClientBookingStatus.awaitingPayment:
        await pushFlow(context, AppRoutes.jobApplicants, arguments: booking.toMap());
      case ClientBookingStatus.requested:
        if (booking.backendStatus == 'draft') {
          await Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => PaymentCheckoutScreen(
                jobId: booking.id,
                amount: double.tryParse(booking.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 20.00,
              ),
            ),
          );
        } else if (booking.backendStatus == 'draft' &&
            booking.jobMode == 'scheduled') {
          AppToast.showInfo(
            context,
            'This scheduled job will start matching before the appointment.',
          );
        } else {
          await pushFlow(context, AppRoutes.jobApplicants,
              arguments: booking.toMap());
        }
      case ClientBookingStatus.accepted:
        await pushFlow(context, AppRoutes.liveTracking, arguments: booking.toMap());
      case ClientBookingStatus.cancelled:
        if (booking.isRecoverableServiceInterruption) {
          await pushFlow(context, AppRoutes.liveTracking, arguments: booking.toMap());
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
    BookingSummarySheet.show(context, booking);
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
