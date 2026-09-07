import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:artisans_app/features/client/presentation/client_shell.dart';
import 'package:artisans_app/features/client/presentation/screens/explore_artisans_screen.dart';
import 'package:artisans_app/features/client/presentation/screens/map_discovery_screen.dart';
import 'package:artisans_app/features/client/presentation/screens/artisan_profile_screen.dart';
import 'package:artisans_app/features/client/presentation/screens/direct_worker_request_screen.dart';
import 'package:artisans_app/features/client/presentation/screens/finding_artisan_screen.dart';
import 'package:artisans_app/features/client/presentation/screens/job_post_category_screen.dart';
import 'package:artisans_app/features/client/presentation/screens/job_post_subcategory_screen.dart';
import 'package:artisans_app/features/client/presentation/screens/job_post_details_screen.dart';
import 'package:artisans_app/features/client/presentation/screens/job_post_location_schedule_screen.dart';
import 'package:artisans_app/features/client/presentation/screens/job_post_summary_screen.dart';
import 'package:artisans_app/features/client/presentation/screens/job_applicants_screen.dart';
import 'package:artisans_app/features/client/presentation/screens/live_tracking_screen.dart';
import 'package:artisans_app/features/client/presentation/screens/payment_checkout_screen.dart';
import 'package:artisans_app/features/client/presentation/screens/rate_service_screen.dart';
import 'package:artisans_app/core/session/app_user_session.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/core/navigation/app_routes.dart';
import 'package:artisans_app/shared/presentation/screens/notifications_screen.dart';
import 'package:artisans_app/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:artisans_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:artisans_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:artisans_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:artisans_app/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:artisans_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:artisans_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:artisans_app/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:artisans_app/features/worker/presentation/worker_shell.dart';
import 'package:artisans_app/features/worker/presentation/widgets/worker_bottom_nav.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_earnings_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_stats_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_booking_history_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_reviews_screen.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_gallery_screen.dart';
import 'package:artisans_app/shared/presentation/screens/chat_detail_screen.dart';
import 'package:artisans_app/shared/presentation/screens/edit_profile_screen.dart';
import 'package:artisans_app/shared/presentation/screens/job_receipt_screen.dart';
import 'package:artisans_app/shared/presentation/screens/messages_list_screen.dart';
import 'package:artisans_app/shared/presentation/screens/settings_screen.dart';
import 'package:artisans_app/shared/presentation/screens/user_profile_screen.dart';
import 'package:artisans_app/features/trust_safety/presentation/screens/my_reports_screen.dart';
import 'package:artisans_app/features/trust_safety/presentation/screens/blocked_users_screen.dart';
import 'package:artisans_app/shared/presentation/screens/payment_success_screen.dart';
import 'package:artisans_app/core/navigation/route_arguments.dart';
import 'package:artisans_app/core/navigation/app_navigation.dart';
import 'package:artisans_app/core/navigation/route_policy.dart';

class AppRouter {
  /// Routes with explicit builders in the central registry. Query strings are
  /// normalized away before lookup, so this set contains path names only.
  static const Set<String> registeredRoutes = <String>{
    AppRoutes.splash,
    AppRoutes.authForgotPassword,
    AppRoutes.authSignIn,
    AppRoutes.authSignUp,
    AppRoutes.authOnboarding,
    AppRoutes.authRole,
    AppRoutes.authVerifyEmail,
    AppRoutes.sharedMessages,
    AppRoutes.sharedChat,
    AppRoutes.sharedProfile,
    AppRoutes.sharedSettings,
    AppRoutes.sharedEditProfile,
    AppRoutes.sharedJobReceipt,
    AppRoutes.myReports,
    AppRoutes.blockedUsers,
    AppRoutes.workerHome,
    AppRoutes.clientHome,
    AppRoutes.clientHomeLegacy,
    AppRoutes.exploreArtisans,
    AppRoutes.artisanProfile,
    AppRoutes.mapDiscovery,
    AppRoutes.findingArtisan,
    AppRoutes.directWorkerRequest,
    AppRoutes.jobPostCategory,
    AppRoutes.jobPostSubcategory,
    AppRoutes.jobPostDetails,
    AppRoutes.jobPostLocationSchedule,
    AppRoutes.jobPostSummary,
    AppRoutes.bookingHistory,
    AppRoutes.liveTracking,
    AppRoutes.jobApplicants,
    AppRoutes.rateService,
    AppRoutes.notifications,
    AppRoutes.wallet,
    AppRoutes.paymentSuccess,
    AppRoutes.paymentCheckout,
    AppRoutes.workerEarnings,
    AppRoutes.workerStats,
    AppRoutes.workerHistory,
    AppRoutes.workerReviews,
    AppRoutes.workerGallery,
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String rawName = settings.name ?? '';
    final Uri uri;
    try {
      uri = Uri.parse(rawName);
    } on FormatException {
      return _page(settings, _NotFoundScreen(routeName: rawName));
    }
    final String routeName = uri.path;

    // All feature routes enter through this boundary, including legacy links.
    // Auth screens and the splash remain publicly reachable.
    if (RoutePolicy.isProtected(routeName) &&
        Supabase.instance.client.auth.currentSession == null) {
      return _page(
        const RouteSettings(name: SignInScreen.routeName),
        const SignInScreen(),
      );
    }
    if (RoutePolicy.requiresWorkerCapability(routeName) &&
        AppUserSession.instance.currentUser != null &&
        !AppUserSession.instance.isWorkerCapable) {
      return _page(
        const RouteSettings(name: AppRoutes.clientHome),
        const ClientShell(),
      );
    }

    switch (routeName) {

      case SplashScreen.routeName:
      case '/auth/splash':
        return _page(settings, const SplashScreen());
      case OnboardingScreen.routeName:
        return _page(settings, const OnboardingScreen());
      case ForgotPasswordScreen.routeName:
        final args = settings.arguments;
        final recoveryArgs = args is ForgotPasswordScreenArgs ? args : null;
        return _page(settings, ForgotPasswordScreen(
          initialEmail: recoveryArgs?.initialEmail ?? (args is String ? args : null),
          isRecoveryFlow: recoveryArgs?.isRecoveryFlow ?? false,
        ));
      case RoleSelectionScreen.routeName:
        return _page(settings, const RoleSelectionScreen());
      case SignInScreen.routeName:
        return _page(settings, SignInScreen(initialEmail: settings.arguments is String ? settings.arguments as String : null));
      case SignUpScreen.routeName:
        return _page(settings, const SignUpScreen());
      case VerifyEmailScreen.routeName:
        return _page(settings, VerifyEmailScreen(email: settings.arguments is String ? settings.arguments as String : ''));
      case MessagesListScreen.routeName:
        return _protectedPage(settings, const MessagesListScreen());
      case ChatDetailScreen.routeName:
        return _protectedPage(settings, const ChatDetailScreen());
      case UserProfileScreen.routeName:
        return _protectedPage(settings, const UserProfileScreen());
      case SettingsScreen.routeName:
        return _protectedPage(settings, const SettingsScreen());
      case EditProfileScreen.routeName:
        return _protectedPage(settings, const EditProfileScreen());
      case JobReceiptScreen.routeName:
        return _protectedPage(settings, const JobReceiptScreen());
      case MyReportsScreen.routeName:
        return _protectedPage(settings, const MyReportsScreen());
      case BlockedUsersScreen.routeName:
        return _protectedPage(settings, const BlockedUsersScreen());
      case WorkerShell.routeName:
        final currentUser = AppUserSession.instance.currentUser;
        if (currentUser != null && !currentUser.hasWorkerProfile) {
          return _page(
            const RouteSettings(name: AppRoutes.clientHome),
            const ClientShell(),
          );
        }
        final args = settings.arguments;
        final initialTabArg = args is Map ? args['initialTab'] : null;
        final initialTab = initialTabArg == 'messages'
            ? WorkerNavTab.messages
            : initialTabArg == 'bookings'
                ? WorkerNavTab.bookings
                : WorkerNavTab.explore;
        return _protectedPage(settings, WorkerShell(
          initialJobRequestId: args is Map ? args['openJobRequestId'] as String? : null,
          initialTab: initialTab,
        ));
      case AppRoutes.workerEarnings:
        return _protectedPage(settings, const WorkerEarningsScreen());
      case AppRoutes.workerStats:
        return _protectedPage(settings, const WorkerStatsScreen());
      case AppRoutes.workerHistory:
        return _protectedPage(settings, const WorkerBookingHistoryScreen());
      case AppRoutes.workerReviews:
        return _protectedPage(settings, const WorkerReviewsScreen());
      case AppRoutes.workerGallery:
        return _protectedPage(settings, const WorkerGalleryScreen());

      case AppRoutes.clientHome:
      case AppRoutes.clientHomeLegacy:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) {
            final Object? args = settings.arguments;
            ClientNavTab initialTab = ClientNavTab.home;
            if (args is Map<String, dynamic>) {
              final Object? tab = args['initialTab'];
              if (tab is ClientNavTab) initialTab = tab;
            }
            return ClientShell(initialTab: initialTab);
          },
        );

      case AppRoutes.exploreArtisans:
        final Object? exploreArgs = settings.arguments;
        String initialQuery = '';
        String initialCategory = '';
        String initialCategoryId = '';
        List<String> initialCategoryIds = const <String>[];
        List<String> initialCategories = const <String>[];
        String? intentSummary;
        if (exploreArgs is Map<String, dynamic>) {
          initialQuery = (exploreArgs['query'] ?? '').toString();
          initialCategory = (exploreArgs['category'] ?? '').toString();
          initialCategoryId = (exploreArgs['categoryId'] ?? '').toString();
          if (exploreArgs['categoryIds'] is List) {
            initialCategoryIds = List<String>.from(exploreArgs['categoryIds'] as List);
          }
          if (exploreArgs['categories'] is List) {
            initialCategories = List<String>.from(exploreArgs['categories'] as List);
          }
          if (exploreArgs['intentSummary'] != null) {
            intentSummary = exploreArgs['intentSummary'].toString();
          }
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ExploreArtisansScreen(
            initialQuery: initialQuery,
            initialCategory: initialCategory,
            initialCategoryId: initialCategoryId,
            initialCategoryIds: initialCategoryIds,
            initialCategories: initialCategories,
            intentSummary: intentSummary,
          ),
        );

      case AppRoutes.mapDiscovery:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MapDiscoveryScreen(),
        );

      case AppRoutes.artisanProfile:
        final profileArgs = ArtisanRouteArgs.tryParse(settings.arguments);
        if (profileArgs == null) {
          return _page(settings, const _InvalidRouteArgumentsScreen());
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ArtisanProfileScreen(
            artisan: profileArgs?.snapshot,
          ),
        );

      case AppRoutes.findingArtisan:
        final Object? findingArgs = settings.arguments;
        Map<String, dynamic>? jobData;
        Map<String, dynamic>? artisan;
        if (findingArgs is Map<String, dynamic>) {
          jobData = findingArgs['jobData'] as Map<String, dynamic>? ??
              findingArgs;
          artisan = findingArgs['artisan'] as Map<String, dynamic>?;
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => FindingArtisanScreen(
            jobData: jobData,
            artisan: artisan,
          ),
        );

      case AppRoutes.directWorkerRequest:
        final requestArgs = ArtisanRouteArgs.tryParse(settings.arguments);
        if (requestArgs == null) {
          return _page(settings, const _InvalidRouteArgumentsScreen());
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DirectWorkerRequestScreen(
            artisan: requestArgs.snapshot,
          ),
        );

      case AppRoutes.jobPostCategory:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => JobPostCategoryScreen(
            jobData: _mapArguments(settings.arguments),
          ),
        );

      case AppRoutes.jobPostSubcategory:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => JobPostSubcategoryScreen(
            jobData: _mapArguments(settings.arguments),
          ),
        );

      case AppRoutes.jobPostDetails:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => JobPostDetailsScreen(
            jobData: _mapArguments(settings.arguments),
          ),
        );

      case AppRoutes.jobPostLocationSchedule:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => JobPostLocationScheduleScreen(
            jobData: _mapArguments(settings.arguments),
          ),
        );

      case AppRoutes.jobPostSummary:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => JobPostSummaryScreen(
            jobData: _mapArguments(settings.arguments),
          ),
        );

      case AppRoutes.bookingHistory:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ClientShell(initialTab: ClientNavTab.bookings),
        );

      case AppRoutes.liveTracking:
        final trackingArgs = JobRouteArgs.tryParse(settings.arguments);
        if (trackingArgs == null) {
          return _page(settings, const _InvalidRouteArgumentsScreen());
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LiveTrackingScreen(
            job: trackingArgs?.toMap(),
          ),
        );

      case AppRoutes.jobApplicants:
        final applicantsArgs = JobRouteArgs.tryParse(settings.arguments);
        if (applicantsArgs == null) {
          return _page(settings, const _InvalidRouteArgumentsScreen());
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => JobApplicantsScreen(
            job: applicantsArgs?.toMap(),
          ),
        );

      case AppRoutes.rateService:
        final Object? rawService = settings.arguments;
        final Map<String, dynamic>? service = rawService is Map
            ? Map<String, dynamic>.from(rawService)
            : null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RateServiceScreen(
            service: service,
          ),
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotificationsScreen(),
        );

      case AppRoutes.wallet:
        final bool isWorker = settings.arguments == true;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => WalletScreen(isWorker: isWorker),
        );

      case AppRoutes.paymentSuccess:
        final Object? rawReference = settings.arguments;
        final String? argumentReference = rawReference is Map
            ? rawReference['reference']?.toString()
            : rawReference is String
                ? rawReference
                : null;
        final String? ref = uri.queryParameters['reference'] ?? argumentReference;
        return _page(settings, PaymentSuccessScreen(reference: ref));

      case AppRoutes.paymentCheckout:
        final args = PaymentCheckoutArgs.tryParse(settings.arguments);
        if (args == null) return _page(settings, const _InvalidRouteArgumentsScreen());
        return _protectedPage(settings, PaymentCheckoutScreen(jobId: args.jobId, amount: args.amount, applicationId: args.applicationId, initialCheckoutUrl: args.initialCheckoutUrl, initialReference: args.initialReference));

      default:
        debugPrint('⚠️ 404: Route not found: ${settings.name}');
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => _NotFoundScreen(routeName: settings.name),
        );
    }
  }

  static MaterialPageRoute<dynamic> _page(RouteSettings settings, Widget child) =>
      MaterialPageRoute<dynamic>(settings: settings, builder: (_) => child);

  static Map<String, dynamic>? _mapArguments(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static Route<dynamic> _protectedPage(RouteSettings settings, Widget child) {
    if (Supabase.instance.client.auth.currentSession == null) {
      return _page(
        RouteSettings(name: SignInScreen.routeName, arguments: settings),
        const SignInScreen(),
      );
    }
    return _page(settings, child);
  }

}

class _InvalidRouteArgumentsScreen extends StatelessWidget {
  const _InvalidRouteArgumentsScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('This action is no longer available.')));
}

class _NotFoundScreen extends StatefulWidget {
  const _NotFoundScreen({this.routeName});

  final String? routeName;

  @override
  State<_NotFoundScreen> createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<_NotFoundScreen> {
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), _goHome);
  }

  void _goHome() {
    if (!mounted || _redirected) return;
    _redirected = true;
    final session = AppUserSession.instance;
    
    // If not authenticated, redirect to sign in instead of client shell
    if (!session.isAuthenticated) {
      AppNavigation.resetToSignIn(context);
      return;
    }

    if (session.isWorkerCapable && session.activeMode == 'worker') {
      AppNavigation.resetToWorker(context);
    } else {
      AppNavigation.resetToClient(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.explore_off, size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                'Page not found',
                style: AppTypography.displayMedium.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.routeName != null
                    ? 'The route "${widget.routeName}" does not exist.'
                    : 'This page does not exist.',
                style: AppTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Taking you home…',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _goHome,
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
