import 'app_routes.dart';

class RoutePolicy {
  const RoutePolicy._();

  static const publicRoutes = <String>{
    AppRoutes.splash,
    '/auth/splash',
    AppRoutes.authOnboarding,
    AppRoutes.authForgotPassword,
    AppRoutes.authRole,
    AppRoutes.authSignIn,
    AppRoutes.authSignUp,
    AppRoutes.authVerifyEmail,
    AppRoutes.paymentSuccess,
  };

  static const protectedRoutes = <String>{
    AppRoutes.clientHome, AppRoutes.clientHomeLegacy,
    AppRoutes.exploreArtisans, AppRoutes.artisanProfile,
    AppRoutes.mapDiscovery, AppRoutes.findingArtisan,
    AppRoutes.directWorkerRequest, AppRoutes.jobPostCategory,
    AppRoutes.jobPostSubcategory, AppRoutes.jobPostDetails,
    AppRoutes.jobPostLocationSchedule, AppRoutes.jobPostSummary,
    AppRoutes.bookingHistory, AppRoutes.liveTracking,
    AppRoutes.jobApplicants, AppRoutes.rateService,
    AppRoutes.notifications, AppRoutes.wallet,
    AppRoutes.paymentCheckout, AppRoutes.workerHome,
    AppRoutes.workerEarnings, AppRoutes.workerStats,
    AppRoutes.workerHistory, AppRoutes.workerReviews,
    AppRoutes.workerGallery, AppRoutes.sharedMessages,
    AppRoutes.sharedChat, AppRoutes.sharedProfile,
    AppRoutes.sharedSettings, AppRoutes.sharedEditProfile,
    AppRoutes.sharedJobReceipt, AppRoutes.myReports,
    AppRoutes.blockedUsers,
  };

  static bool isProtected(String routeName) => protectedRoutes.contains(routeName);
  static bool requiresWorkerCapability(String routeName) =>
      routeName == AppRoutes.workerHome || routeName.startsWith('/worker/');
}
