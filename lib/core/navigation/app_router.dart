import 'package:flutter/material.dart';

import '../../features/client/presentation/client_shell.dart';
import '../../features/client/presentation/screens/explore_artisans_screen.dart';
import '../../features/client/presentation/screens/map_discovery_screen.dart';
import '../../features/client/presentation/screens/artisan_profile_screen.dart';
import '../../features/client/presentation/screens/direct_worker_request_screen.dart';
import '../../features/client/presentation/screens/finding_artisan_screen.dart';
import '../../features/client/presentation/screens/job_post_category_screen.dart';
import '../../features/client/presentation/screens/job_post_subcategory_screen.dart';
import '../../features/client/presentation/screens/job_post_details_screen.dart';
import '../../features/client/presentation/screens/job_post_location_schedule_screen.dart';
import '../../features/client/presentation/screens/job_post_summary_screen.dart';
import '../../features/client/presentation/screens/live_tracking_screen.dart';
import '../../features/client/presentation/screens/rate_service_screen.dart';
import '../session/app_user_session.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_routes.dart';
import 'auth_navigation.dart';
import '../../shared/presentation/screens/notifications_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case AppRoutes.clientHome:
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
        if (exploreArgs is Map<String, dynamic>) {
          initialQuery = (exploreArgs['query'] ?? '').toString();
          initialCategory = (exploreArgs['category'] ?? '').toString();
          initialCategoryId = (exploreArgs['categoryId'] ?? '').toString();
        }
        return MaterialPageRoute(
          builder: (_) => ExploreArtisansScreen(
            initialQuery: initialQuery,
            initialCategory: initialCategory,
            initialCategoryId: initialCategoryId,
          ),
        );

      case AppRoutes.mapDiscovery:
        return MaterialPageRoute(
          builder: (_) => const MapDiscoveryScreen(),
        );

      case AppRoutes.artisanProfile:
        return MaterialPageRoute(
          builder: (_) => ArtisanProfileScreen(
            artisan: settings.arguments as Map<String, dynamic>?,
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
          builder: (_) => FindingArtisanScreen(
            jobData: jobData,
            artisan: artisan,
          ),
        );

      case AppRoutes.directWorkerRequest:
        return MaterialPageRoute(
          builder: (_) => DirectWorkerRequestScreen(
            artisan: settings.arguments as Map<String, dynamic>?,
          ),
        );

      case AppRoutes.jobPostCategory:
        return MaterialPageRoute(
          builder: (_) => JobPostCategoryScreen(
            jobData: settings.arguments as Map<String, dynamic>?,
          ),
        );

      case AppRoutes.jobPostSubcategory:
        return MaterialPageRoute(
          builder: (_) => JobPostSubcategoryScreen(
            jobData: settings.arguments as Map<String, dynamic>?,
          ),
        );

      case AppRoutes.jobPostDetails:
        return MaterialPageRoute(
          builder: (_) => JobPostDetailsScreen(
            jobData: settings.arguments as Map<String, dynamic>?,
          ),
        );

      case AppRoutes.jobPostLocationSchedule:
        return MaterialPageRoute(
          builder: (_) => JobPostLocationScheduleScreen(
            jobData: settings.arguments as Map<String, dynamic>?,
          ),
        );

      case AppRoutes.jobPostSummary:
        return MaterialPageRoute(
          builder: (_) => JobPostSummaryScreen(
            jobData: settings.arguments as Map<String, dynamic>?,
          ),
        );

      case AppRoutes.bookingHistory:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ClientShell(initialTab: ClientNavTab.bookings),
        );

      case AppRoutes.liveTracking:
        return MaterialPageRoute(
          builder: (_) => LiveTrackingScreen(
            job: settings.arguments as Map<String, dynamic>?,
          ),
        );

      case AppRoutes.rateService:
        return MaterialPageRoute(
          builder: (_) => RateServiceScreen(
            service: settings.arguments as Map<String, dynamic>?,
          ),
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );

      default:
        debugPrint('⚠️ 404: Route not found: ${settings.name}');
        return MaterialPageRoute(
          builder: (_) => _NotFoundScreen(routeName: settings.name),
        );
    }
  }
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
    final String route = shellRouteForMode(
      session.activeMode,
      session.isWorkerCapable,
    );
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
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
