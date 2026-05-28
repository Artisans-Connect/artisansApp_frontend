import 'package:flutter/material.dart';
import '../../features/client/presentation/client_shell.dart';
import '../../features/client/presentation/screens/explore_artisans_screen.dart';
import '../../features/client/presentation/screens/map_discovery_screen.dart';
import '../../features/client/presentation/screens/artisan_profile_screen.dart';
import '../../features/client/presentation/screens/finding_artisan_screen.dart';
import '../../features/client/presentation/screens/job_post_category_screen.dart';
import '../../features/client/presentation/screens/job_post_subcategory_screen.dart';
import '../../features/client/presentation/screens/job_post_title_screen.dart';
import '../../features/client/presentation/screens/job_post_description_screen.dart';
import '../../features/client/presentation/screens/job_post_location_screen.dart';
import '../../features/client/presentation/screens/job_post_urgency_screen.dart';
import '../../features/client/presentation/screens/job_post_summary_screen.dart';
import '../../features/client/presentation/screens/live_tracking_screen.dart';
import '../../features/client/presentation/screens/rate_service_screen.dart';
import 'app_routes.dart';

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
        return MaterialPageRoute(
          builder: (_) => const ExploreArtisansScreen(),
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

      case AppRoutes.jobPostTitle:
        return MaterialPageRoute(
          builder: (_) => JobPostTitleScreen(
            jobData: settings.arguments as Map<String, dynamic>?,
          ),
        );

      case AppRoutes.jobPostDescription:
        return MaterialPageRoute(
          builder: (_) => JobPostDescriptionScreen(
            jobData: settings.arguments as Map<String, dynamic>?,
          ),
        );

      case AppRoutes.jobPostLocation:
        return MaterialPageRoute(
          builder: (_) => JobPostLocationScreen(
            jobData: settings.arguments as Map<String, dynamic>?,
          ),
        );

      case AppRoutes.jobPostUrgency:
        return MaterialPageRoute(
          builder: (_) => JobPostUrgencyScreen(
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

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route not found")),
          ),
        );
    }
  }
}