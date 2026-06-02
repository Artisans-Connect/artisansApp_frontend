import 'package:flutter/material.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/utils/current_user.dart';
import '../../../../shared/presentation/navigation/shared_route_args.dart';
import '../../../../shared/models/conversation_summary.dart';
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

  static void openChat(
    BuildContext context, {
    required String conversationId,
    required String counterpartUserId,
    required String counterpartName,
    String? jobId,
    String? jobTitle,
  }) {
    Navigator.pushNamed(
      context,
      ChatDetailScreen.routeName,
      arguments: ChatDetailArgs(
        conversationId: conversationId,
        counterpartUserId: counterpartUserId,
        counterpartName: counterpartName,
        jobId: jobId,
        jobTitle: jobTitle,
      ),
    );
  }

  static void showCallPlaceholder(BuildContext context, String phone) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Call artisan'),
        content: Text('Would call $phone (UI stub).'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
  }) {
    Navigator.pushNamed(
      context,
      UserProfileScreen.routeName,
      arguments: ProfileArgs(userId: userId, viewAsWorker: true),
    );
  }

  static void openChatForArtisan(
    BuildContext context,
    Map<String, dynamic> artisan,
  ) {
    final String name = artisan['name'] as String? ?? 'Artisan';
    final String workerId =
        artisan['id'] as String? ?? artisan['worker_id'] as String? ?? '';
    openChat(
      context,
      conversationId: workerId.isNotEmpty ? workerId : 'conv-$name',
      counterpartUserId: workerId.isNotEmpty ? workerId : 'worker-unknown',
      counterpartName: name,
      jobTitle: artisan['profession'] as String?,
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
