class AppRoutes {
  // Main flows
  static const splash = '/';
  static const authForgotPassword = '/auth/forgot-password';
  static const authSignIn = '/auth/sign-in';
  static const authSignUp = '/auth/sign-up';
  static const authOnboarding = '/auth/onboarding';
  static const authRole = '/auth/role';
  static const authVerifyEmail = '/auth/verify-email';
  static const sharedMessages = '/shared/messages';
  static const sharedChat = '/shared/chat';
  static const sharedProfile = '/shared/profile';
  static const sharedSettings = '/shared/settings';
  static const sharedEditProfile = '/shared/edit-profile';
  static const sharedJobReceipt = '/shared/job-receipt';
  static const myReports = '/my-reports';
  static const blockedUsers = '/blocked-users';
  static const workerHome = '/shared/worker-home';
  static const clientHome = '/client-shell';
  static const clientHomeLegacy = '/client-home';
  static const exploreArtisans = '/explore-artisans';
  static const artisanProfile = '/artisan-profile';
  static const mapDiscovery = '/map-discovery';
  static const findingArtisan = '/finding-artisan';
  static const directWorkerRequest = '/direct-worker-request';

  // Job Post Flow
  static const jobPostCategory = '/job-post-category';
  static const jobPostSubcategory = '/job-post-subcategory';
  static const jobPostDetails = '/job-post-details';
  static const jobPostLocationSchedule = '/job-post-location-schedule';
  static const jobPostSummary = '/job-post-summary';

  // Service Tracking Flow
  static const bookingHistory = '/booking-history';
  static const liveTracking = '/live-tracking';
  static const jobApplicants = '/job-applicants';
  static const rateService = '/rate-service';

  // Shared
  static const notifications = '/notifications';
  static const wallet = '/wallet';
  static const paymentSuccess = '/payment-success';
  static const paymentCheckout = '/payment-checkout';
  static const workerEarnings = '/worker/earnings';
  static const workerStats = '/worker/stats';
  static const workerHistory = '/worker/history';
  static const workerReviews = '/worker/reviews';
  static const workerGallery = '/worker/gallery';

  static const all = <String>{
    splash, authForgotPassword, authSignIn, authSignUp, authOnboarding,
    authRole, authVerifyEmail, sharedMessages, sharedChat, sharedProfile,
    sharedSettings, sharedEditProfile, sharedJobReceipt, myReports,
    blockedUsers, workerHome, clientHome, clientHomeLegacy, exploreArtisans,
    artisanProfile, mapDiscovery, findingArtisan, directWorkerRequest,
    jobPostCategory, jobPostSubcategory, jobPostDetails,
    jobPostLocationSchedule, jobPostSummary, bookingHistory, liveTracking,
    jobApplicants, rateService, notifications, wallet, paymentSuccess,
    paymentCheckout, workerEarnings, workerStats, workerHistory,
    workerReviews, workerGallery,
  };
}
