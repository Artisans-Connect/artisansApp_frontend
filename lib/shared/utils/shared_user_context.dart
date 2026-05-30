import '../../core/session/app_user_session.dart';
import '../../core/utils/current_user.dart';
import '../../features/auth/models/onboarding_session.dart';
import '../data/shared_stub_data.dart';
import '../models/user_profile_view.dart';
import '../presentation/navigation/shared_route_args.dart';

/// Resolves the logged-in user's role and merged profile for shared screens.
class SharedUserContext {
  SharedUserContext._();

  static OnboardingSession get session => OnboardingSession.instance;

  static UserRole get currentRole {
    if (CurrentUser.role != null) return CurrentUser.role!;
    if (session.hasRole) return session.role!;
    return SharedStubData.currentUserProfile.role;
  }

  static bool get isWorker => currentRole == UserRole.worker;
  static bool get isClient => currentRole == UserRole.client;

  static String? get currentUserId => CurrentUser.id;

  static bool isOwnProfile(String? userId) =>
      userId == null || userId == currentUserId;

  static UserProfileViewData resolveProfile(ProfileArgs? args) {
    if (args == null || isOwnProfile(args.userId)) {
      return buildOwnProfile();
    }
    if (args.userId == SharedStubData.sampleWorkerProfile.id || args.viewAsWorker) {
      return SharedStubData.sampleWorkerProfile;
    }
    return SharedStubData.sampleClientProfile;
  }

  static UserProfileViewData buildOwnProfile() {
    final AppUser? appUser = AppUserSession.instance.currentUser;
    if (appUser != null) {
      final UserRole role =
          appUser.role == 'worker' || appUser.role == 'artisan'
              ? UserRole.worker
              : UserRole.client;
      return UserProfileViewData(
        id: appUser.id,
        fullName: appUser.fullName,
        role: role,
        phone: appUser.phone ?? session.phone,
        bio: session.bio,
        avatarUrl: appUser.avatarUrl,
        locationLabel: session.locationLabel,
        rating: role == UserRole.worker ? 4.8 : null,
        totalJobs: role == UserRole.worker ? 0 : null,
        skills: session.selectedTrades.isNotEmpty
            ? session.selectedTrades.toList()
            : const <String>[],
        serviceAreas: session.serviceAreas.isNotEmpty
            ? session.serviceAreas.toList()
            : const <String>[],
        experienceBand: session.experienceBand,
        isVerified: false,
      );
    }

    final UserProfileViewData base = SharedStubData.currentUserProfile;
    final UserRole role = currentRole;
    return UserProfileViewData(
      id: currentUserId ?? base.id,
      fullName: session.fullName ?? base.fullName,
      role: role,
      phone: session.phone ?? base.phone,
      bio: session.bio ?? base.bio,
      avatarUrl: base.avatarUrl,
      locationLabel: session.locationLabel ?? base.locationLabel,
      rating: role == UserRole.worker ? (base.rating ?? 4.8) : base.rating,
      totalJobs: role == UserRole.worker ? (base.totalJobs ?? 0) : base.totalJobs,
      skills: session.selectedTrades.isNotEmpty
          ? session.selectedTrades.toList()
          : base.skills,
      serviceAreas: session.serviceAreas.isNotEmpty
          ? session.serviceAreas.toList()
          : base.serviceAreas,
      experienceBand: session.experienceBand ?? base.experienceBand,
      isVerified: base.isVerified,
    );
  }
}
