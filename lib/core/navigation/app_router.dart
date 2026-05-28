import 'package:flutter/material.dart';
import '../../features/client/presentation/screens/client_home_screen.dart';
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
import '../../features/client/presentation/screens/booking_history_screen.dart';
import '../../features/client/presentation/screens/live_tracking_screen.dart';
import '../../features/client/presentation/screens/rate_service_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case AppRoutes.clientHome:
        return MaterialPageRoute(
          builder: (_) => const ClientHomeScreen(),
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
        return MaterialPageRoute(
          builder: (_) => const FindingArtisanScreen(),
        );

      case AppRoutes.jobPostCategory:
        return MaterialPageRoute(
          builder: (_) => const JobPostCategoryScreen(),
        );

      case AppRoutes.jobPostSubcategory:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => JobPostSubcategoryScreen(
            jobData: args?['jobData'],
          ),
        );

      case AppRoutes.jobPostTitle:
      final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => JobPostTitleScreen(
            jobData: args?['jobData'],
          ),
        );

      case AppRoutes.jobPostDescription:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => JobPostDescriptionScreen(
            jobData: args?['jobData'],
          ),
        );

      case AppRoutes.jobPostLocation:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => JobPostLocationScreen(
            jobData: args?['jobData'],
          ),
        );

      case AppRoutes.jobPostUrgency:
      final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => JobPostUrgencyScreen(
            jobData: args?['jobData'],
          ),
        );

      case AppRoutes.jobPostSummary:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => JobPostSummaryScreen(
            jobData: args?['jobData'],
          ),
        );

      case AppRoutes.bookingHistory:
        return MaterialPageRoute(
          builder: (_) => const BookingHistoryScreen(),
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