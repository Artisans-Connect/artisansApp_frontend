import '../../core/session/app_user_session.dart';
import '../../core/utils/current_user.dart';
import '../../features/auth/models/onboarding_session.dart';
import '../data/shared_stub_data.dart';
import '../models/user_profile_view.dart';
import '../presentation/navigation/shared_route_args.dart';

/// Resolves the logged-in user's active mode and merged profile for shared screens.
class SharedUserContext {
  SharedUserContext._();

  static OnboardingSession get session => OnboardingSession.instance;

  static UserRole get currentRole {
    if (CurrentUser.role != null) return CurrentUser.role!;
    if (session.hasRole) return session.role!;
    return SharedStubData.currentUserProfile.role;
  }

  static bool get isViewingAsWorker =>
      CurrentUser.activeMode == 'worker' && CurrentUser.isWorkerCapable;

  static bool get canSwitchToWorker =>
      CurrentUser.isWorkerCapable && !isViewingAsWorker;

  static bool get isWorkerCapable => CurrentUser.isWorkerCapable;

  static bool get isWorker => CurrentUser.role == UserRole.worker;

  static bool get isClient => CurrentUser.role != UserRole.worker;

  static String? get currentUserId => CurrentUser.id;

  static bool isOwnProfile(String? userId) =>
      userId == null || userId == currentUserId;

  static UserProfileViewData resolveProfile(ProfileArgs? args) {
    if (args == null || isOwnProfile(args.userId)) {
      return buildOwnProfile();
    }

    if (args.profileData != null) {
      return _profileFromMap(args.profileData!);
    }

    return SharedStubData.sampleClientProfile;
  }

  static UserProfileViewData _profileFromMap(Map<String, dynamic> data) {
    final Map<String, dynamic> nestedProfile =
        Map<String, dynamic>.from(data['profiles'] as Map<String, dynamic>? ?? const <String, dynamic>{});
    final List<String> skills = (data['skills'] ?? nestedProfile['skills'] ?? <dynamic>[])
        .map((dynamic item) => item.toString())
        .toList();
    final List<String> serviceAreas = (data['serviceAreas'] ?? nestedProfile['service_areas'] ?? <dynamic>[])
        .map((dynamic item) => item.toString())
        .toList();

    return UserProfileViewData(
      id: (data['id'] ?? data['userId'] ?? nestedProfile['id'] ?? '').toString(),
      fullName: (data['name'] ?? nestedProfile['full_name'] ?? 'Artisan').toString(),
      role: UserRole.worker,
      phone: (data['phone'] ?? nestedProfile['phone']).toString().isNotEmpty
          ? (data['phone'] ?? nestedProfile['phone']).toString()
          : null,
      bio: (data['bio'] ?? nestedProfile['bio'] ?? 'No bio yet.').toString(),
      avatarUrl: (data['imageUrl'] ?? nestedProfile['avatar_url'] ?? data['avatar_url']).toString().isNotEmpty
          ? (data['imageUrl'] ?? nestedProfile['avatar_url'] ?? data['avatar_url']).toString()
          : null,
      locationLabel: (data['location'] ?? nestedProfile['location_label'] ?? '').toString().isNotEmpty
          ? (data['location'] ?? nestedProfile['location_label']).toString()
          : null,
      rating: (data['rating'] as num?)?.toDouble() ?? (nestedProfile['rating'] as num?)?.toDouble(),
      totalJobs: (data['totalJobs'] as num?)?.toInt() ?? (data['jobsCompleted'] as num?)?.toInt(),
      skills: skills,
      serviceAreas: serviceAreas,
      experienceBand: (data['experienceBand'] ?? nestedProfile['experience_band']).toString().isNotEmpty
          ? (data['experienceBand'] ?? nestedProfile['experience_band']).toString()
          : null,
      isVerified: data['isVerified'] as bool? ?? nestedProfile['is_verified'] as bool? ?? false,
    );
  }

  static UserProfileViewData buildOwnProfile() {
    final AppUser? appUser = AppUserSession.instance.currentUser;
    if (appUser != null) {
      final UserRole role = isViewingAsWorker ? UserRole.worker : UserRole.client;
      return UserProfileViewData(
        id: appUser.id,
        fullName: appUser.fullName,
        role: role,
        phone: appUser.phone ?? session.phone,
        bio: appUser.bio ?? session.bio,
        avatarUrl: appUser.avatarUrl,
        locationLabel: appUser.locationLabel ?? session.locationLabel,
        rating: role == UserRole.worker ? 4.8 : null,
        totalJobs: role == UserRole.worker ? 0 : null,
        skills: appUser.skills.isNotEmpty
            ? appUser.skills
            : session.selectedTrades.toList(),
        serviceAreas: appUser.serviceAreas.isNotEmpty
            ? appUser.serviceAreas
            : session.serviceAreas.toList(),
        experienceBand: appUser.experienceBand ?? session.experienceBand,
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
