import '../../features/auth/models/onboarding_session.dart';
import '../data/shared_stub_data.dart';
import '../models/user_profile_view.dart';
import '../presentation/navigation/shared_route_args.dart';

/// Resolves the logged-in user's role and merged profile for shared screens.
///
/// Both workers and clients use the same routes (`/shared/profile`, settings,
/// edit-profile). Branch UI on [currentRole] for "me", and on [UserProfileViewData.role]
/// when viewing someone else.
class SharedUserContext {
  SharedUserContext._();

  static OnboardingSession get session => OnboardingSession.instance;

  /// Role of the signed-in user (session wins; stub fallback for dev).
  static UserRole get currentRole {
    if (session.hasRole) return session.role!;
    return SharedStubData.currentUserProfile.role;
  }

  static bool get isWorker => currentRole == UserRole.worker;
  static bool get isClient => currentRole == UserRole.client;

  static bool isOwnProfile(String? userId) =>
      userId == null || userId == SharedStubData.currentUserId;

  static UserProfileViewData resolveProfile(ProfileArgs? args) {
    if (args == null || isOwnProfile(args.userId)) {
      return buildOwnProfile();
    }
    if (args.userId == SharedStubData.sampleWorkerProfile.id || args.viewAsWorker) {
      return SharedStubData.sampleWorkerProfile;
    }
    return SharedStubData.sampleClientProfile;
  }

  /// Profile for the logged-in user after onboarding (session + stub merge).
  static UserProfileViewData buildOwnProfile() {
    final UserProfileViewData base = SharedStubData.currentUserProfile;
    final UserRole role = currentRole;
    return UserProfileViewData(
      id: base.id,
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
