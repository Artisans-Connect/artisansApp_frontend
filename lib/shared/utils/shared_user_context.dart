import 'package:artisans_app/core/session/app_user_session.dart';
import 'package:artisans_app/core/utils/current_user.dart';
import 'package:artisans_app/shared/models/onboarding_session.dart';
import 'package:artisans_app/shared/models/user_profile_view.dart';
import 'package:artisans_app/shared/presentation/navigation/shared_route_args.dart';

/// Resolves the logged-in user's active mode and merged profile for shared screens.
class SharedUserContext {
  SharedUserContext._();

  static OnboardingSession get session => OnboardingSession.instance;

  static UserRole get currentRole {
    if (CurrentUser.role != null) return CurrentUser.role!;
    if (session.hasRole) return session.role!;
    return UserRole.client;
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

    return UserProfileViewData(
      id: args.userId,
      fullName: 'Unknown user',
      role: args.viewAsWorker == true ? UserRole.worker : UserRole.client,
    );
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
        rating: null,
        totalJobs: null,
        skills: appUser.skills.isNotEmpty
            ? appUser.skills
            : session.selectedTrades.toList(),
        serviceAreas: appUser.serviceAreas.isNotEmpty
            ? appUser.serviceAreas
            : session.serviceAreas.toList(),
        experienceBand: appUser.experienceBand ?? session.experienceBand,
        isVerified: role == UserRole.worker && appUser.isVerified,
      );
    }

    final UserRole role = currentRole;
    return UserProfileViewData(
      id: currentUserId ?? '',
      fullName: session.fullName ?? CurrentUser.email ?? 'Account',
      role: role,
      phone: session.phone,
      bio: session.bio,
      locationLabel: session.locationLabel,
      rating: null,
      totalJobs: null,
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
}
