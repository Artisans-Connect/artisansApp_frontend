import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/chat_service.dart';
import '../../../../core/utils/current_user.dart';
import '../../../../shared/presentation/navigation/shared_route_args.dart';
import '../../../../shared/presentation/screens/chat_detail_screen.dart';
import '../../../../shared/presentation/screens/messages_list_screen.dart';
import '../../../../shared/presentation/screens/settings_screen.dart';
import '../../../../shared/presentation/screens/user_profile_screen.dart';
import '../client_shell.dart';
import '../models/client_booking_stub.dart';
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
          route.settings.name == ClientShell.routeName,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This conversation is not ready yet.',
          ),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This worker has no phone number yet.')),
      );
      return;
    }
    final bool launched = await launchUrl(Uri(scheme: 'tel', path: cleaned));
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start a call to $phone.')),
      );
    }
  }

  static void goToBookingsTab(BuildContext context) {
    popToShellAndSelectTab(context, ClientNavTab.bookings);
  }

  static void goToMessagesTab(BuildContext context) {
    popToShellAndSelectTab(context, ClientNavTab.messages);
  }

  static void openMessages(BuildContext context) {
    Navigator.pushNamed(context, MessagesListScreen.routeName);
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
      UserProfileScreen.routeName,
      arguments: ProfileArgs(
        userId: userId,
        viewAsWorker: true,
        profileData: artisan,
      ),
    );
  }

  static Future<void> openChatForArtisan(
    BuildContext context,
    Map<String, dynamic> artisan,
  ) async {
    final String? jobId = artisan['job_id'] as String? ?? artisan['jobId'] as String?;
    if (!isValidJobChatId(jobId)) {
      final Map<String, dynamic> profile = Map<String, dynamic>.from(artisan['profiles'] as Map<String, dynamic>? ?? const <String, dynamic>{});
      final String workerId = (artisan['id'] ?? artisan['worker_id'] ?? artisan['userId'] ?? profile['id'] ?? '').toString();
      final String name = (artisan['name'] ?? profile['full_name'] ?? 'Artisan').toString();
      final String? phone = (artisan['phone'] ?? profile['phone']) as String?;
      if (workerId.isEmpty || workerId == CurrentUser.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot message this profile.')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start this enquiry.')),
        );
      }
      return;
    }
    final Map<String, dynamic> profile = Map<String, dynamic>.from(artisan['profiles'] as Map<String, dynamic>? ?? const <String, dynamic>{});
    final String name = (artisan['name'] ?? profile['full_name'] ?? 'Artisan').toString();
    final String workerId = (artisan['id'] ?? artisan['worker_id'] ?? artisan['userId'] ?? profile['id'] ?? '').toString();
    final String? phone = (artisan['phone'] ?? profile['phone']) as String?;
    openChat(
      context,
      conversationId: jobId!,
      counterpartUserId: workerId.isNotEmpty ? workerId : 'worker-unknown',
      counterpartName: name,
      jobId: jobId,
      jobTitle: (artisan['profession'] ?? (artisan['skills'] is List && (artisan['skills'] as List).isNotEmpty ? (artisan['skills'] as List).first.toString() : null)).toString(),
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
      (Route<dynamic> route) =>
          route.settings.name == ClientShell.routeName,
      arguments: booking,
    );
  }

  static void handleBookingTap(BuildContext context, ClientBooking booking) {
    switch (booking.status) {
      case ClientBookingStatus.inProgress:
        pushFlow(context, AppRoutes.liveTracking, arguments: booking.toMap());
      case ClientBookingStatus.completed:
        if (booking.canRate) {
          pushFlow(context, AppRoutes.rateService, arguments: booking.toMap());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${booking.title} — rated ${booking.rating}★'),
            ),
          );
        }
      case ClientBookingStatus.requested:
        startFindingArtisan(
          context,
          jobData: <String, dynamic>{
            if (booking.jobUuid != null) 'id': booking.jobUuid,
            'title': booking.title,
          },
          artisan: <String, dynamic>{
            'name': booking.artisan,
            'profession': booking.profession,
            'imageUrl': booking.imageUrl,
          },
        );
      case ClientBookingStatus.accepted:
        pushFlow(context, AppRoutes.liveTracking, arguments: booking.toMap());
      case ClientBookingStatus.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${booking.title} was cancelled.')),
        );
    }
  }
}
