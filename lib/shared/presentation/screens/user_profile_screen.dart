import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/auth_navigation.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/verification_service.dart';
import '../../../core/session/app_user_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/errors/error_messages.dart';
import '../../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/profile_section_card.dart';
import '../../widgets/artisan_logo_avatar.dart';
import '../navigation/shared_route_args.dart';
import '../../utils/shared_user_context.dart';
import '../../models/user_profile_view.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

/// Shared profile for clients and workers. Same route; sections vary by [UserProfileViewData.role].
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
    this.embedInShell = false,
    this.onOpenWorkerEarnings,
    this.onOpenWorkerStats,
    this.onOpenWorkerHistory,
    this.onOpenWorkerReviews,
    this.onOpenWorkerGallery,
  });

  static const String routeName = '/shared/profile';

  /// When true, user is inside worker shell — Settings live on another tab.
  final bool embedInShell;
  final VoidCallback? onOpenWorkerEarnings;
  final VoidCallback? onOpenWorkerStats;
  final VoidCallback? onOpenWorkerHistory;
  final VoidCallback? onOpenWorkerReviews;
  final VoidCallback? onOpenWorkerGallery;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _hasRequestedOwnProfileRefresh = false;

  Future<void> _refreshOwnProfile() async {
    try {
      await ProfileService.instance.getMyProfile(forceRefresh: true);
      if (mounted) setState(() {});
    } catch (_) {
      // Keep the cached/session profile visible if refresh is unavailable.
    }
  }

  Future<void> _openVerificationPortal() async {
    try {
      await VerificationService.instance.openPortalAndRefreshProfile();
      if (!mounted) return;
      AppToast.showSuccess(context, 'Verification portal opened.');
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        e,
        fallback: 'Could not open verification portal.',
      );
    }
  }

  Future<void> _switchView(String targetMode) async {
    try {
      await AuthService.instance.updateActiveMode(targetMode);
      if (!mounted) return;
      final String route = shellRouteForMode(
        targetMode,
        AppUserSession.instance.isWorkerCapable,
      );
      await Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not switch view.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Object? rawArgs = ModalRoute.of(context)?.settings.arguments;
    final ProfileArgs? args = rawArgs is ProfileArgs ? rawArgs : null;
    final bool isOwnProfile = SharedUserContext.isOwnProfile(args?.userId);
    if (isOwnProfile && !_hasRequestedOwnProfileRefresh) {
      _hasRequestedOwnProfileRefresh = true;
      unawaited(_refreshOwnProfile());
    }
    if (!isOwnProfile && args?.profileData == null && args?.userId.isNotEmpty == true) {
      return _RemoteProfileScaffold(userId: args!.userId);
    }

    final UserProfileViewData profile = SharedUserContext.resolveProfile(args);
    return _buildScaffold(context, profile, isOwnProfile);
  }

  Widget _buildScaffold(
    BuildContext context,
    UserProfileViewData profile,
    bool isOwnProfile,
  ) {
    final bool isWorkerView = profile.isWorker;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: isOwnProfile ? 'My Profile' : 'Profile',
        showBackButton: !widget.embedInShell,
        actions: <Widget>[
          if (isOwnProfile)
            IconButton(
              onPressed: () => unawaited(
                Navigator.pushNamed(context, EditProfileScreen.routeName)
                    .then((_) {
                  if (mounted) setState(() {});
                }),
              ),
              icon: Icon(PhosphorIcons.pencilSimple, color: AppColors.primary),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _ProfileHero(profile: profile),
              const SizedBox(height: 20),
              if (profile.locationLabel != null &&
                  profile.locationLabel!.isNotEmpty) ...<Widget>[
                ProfileSectionCard(
                  title: 'Location',
                  child: _InfoRow(
                    icon: PhosphorIcons.mapPin,
                    label: profile.locationLabel!,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              ProfileSectionCard(
                title: 'Contact',
                child: profile.phone != null
                    ? _InfoRow(
                        icon: PhosphorIcons.phone,
                        label: profile.phone!,
                      )
                    : Text('No phone added yet.', style: AppTypography.bodyMedium),
              ),
              const SizedBox(height: 14),
              ProfileSectionCard(
                title: 'About',
                child: Text(
                  profile.bio ?? 'No bio yet.',
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
              if (isOwnProfile) ...<Widget>[
                const SizedBox(height: 14),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.wallet,
                      arguments: isWorkerView,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              PhosphorIcons.wallet,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'My Wallet & Credits',
                                  style: AppTypography.titleLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isWorkerView ? 'Manage balance & cash-out to MoMo' : 'View credits, refunds & transaction history',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            PhosphorIcons.caretRight,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (isWorkerView) ...<Widget>[
                if (isOwnProfile) ...<Widget>[
                  const SizedBox(height: 14),
                  FutureBuilder<VerificationContext>(
                    future: VerificationService.instance.getMyVerification(),
                    builder: (context, snapshot) {
                      final contextData = snapshot.data;
                      return _VerificationCard(
                        profile: profile,
                        verification: contextData,
                        isLoading:
                            snapshot.connectionState != ConnectionState.done,
                        onOpenPortal: _openVerificationPortal,
                      );
                    },
                  ),
                ],
                if (profile.skills.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  ProfileSectionCard(
                    title: 'Skills & trades',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.skills
                          .map(
                            (String skill) => Chip(
                              label: Text(skill),
                              backgroundColor: AppColors.surfaceDim,
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                if (profile.serviceAreas.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  ProfileSectionCard(
                    title: 'Service areas',
                    child: Text(
                      profile.serviceAreas.join(', '),
                      style: AppTypography.bodyLarge,
                    ),
                  ),
                ],
                if (profile.experienceBand != null) ...<Widget>[
                  const SizedBox(height: 14),
                  ProfileSectionCard(
                    title: 'Experience',
                    child: Text(
                      profile.experienceBand!,
                      style: AppTypography.bodyLarge,
                    ),
                  ),
                ],
                if (profile.rating != null || profile.totalJobs != null) ...[
                  const SizedBox(height: 14),
                  ProfileSectionCard(
                    title: 'Stats',
                    child: Row(
                      children: <Widget>[
                        if (profile.rating != null)
                          Expanded(
                            child: _StatBlock(
                              label: 'Rating',
                              value: profile.rating!.toStringAsFixed(1),
                            ),
                          ),
                        if (profile.rating != null && profile.totalJobs != null)
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.outlineVariant,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        if (profile.totalJobs != null)
                          Expanded(
                            child: _StatBlock(
                              label: 'Jobs completed',
                              value: '${profile.totalJobs}',
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              if (isOwnProfile) ...<Widget>[
                GradientButton(
                  label: 'Edit Profile',
                  onPressed: () => unawaited(
                    Navigator.pushNamed(
                      context,
                      EditProfileScreen.routeName,
                    ).then((_) {
                      if (mounted) setState(() {});
                    }),
                  ),
                ),
                if (SharedUserContext.isViewingAsWorker) ...<Widget>[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _switchView('client'),
                    child: const Text('Switch to Client View'),
                  ),
                ] else if (SharedUserContext.canSwitchToWorker) ...<Widget>[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _switchView('worker'),
                    child: const Text('Switch to Worker View'),
                  ),
                ] else if (!SharedUserContext.isWorkerCapable) ...<Widget>[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => unawaited(
                      Navigator.pushNamed(
                        context,
                        RoleSelectionScreen.routeName,
                        arguments: <String, dynamic>{'isBecomingWorker': true},
                      ),
                    ),
                    child: const Text('Become a Worker'),
                  ),
                ],
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => unawaited(
                    Navigator.pushNamed(
                      context,
                      SettingsScreen.routeName,
                    ),
                  ),
                  child: Text(
                    SharedUserContext.isWorker
                        ? 'Account settings'
                        : 'Settings & info',
                  ),
                ),
              ] else
                GradientButton(
                  label: 'Message',
                  onPressed: () => unawaited(Navigator.maybePop(context)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({
    required this.profile,
    required this.verification,
    required this.isLoading,
    required this.onOpenPortal,
  });

  final UserProfileViewData profile;
  final VerificationContext? verification;
  final bool isLoading;
  final VoidCallback onOpenPortal;

  @override
  Widget build(BuildContext context) {
    final bool isVerified = profile.isVerified || (verification?.isVerified ?? false);
    final bool hasTrackableApplication = verification?.hasApplication ?? false;
    final bool hasUntrackableStatus =
        !isVerified && (verification?.hasUntrackableStatus ?? false);
    final String? status = hasTrackableApplication ? verification?.status : null;

    return ProfileSectionCard(
      title: 'Verification',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                backgroundColor: isVerified
                    ? AppColors.success.withAlpha(31)
                    : AppColors.primary.withAlpha(26),
                child: Icon(
                  isVerified ? PhosphorIcons.sealCheck : PhosphorIcons.shieldCheck,
                  color: isVerified ? AppColors.success : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      hasUntrackableStatus
                          ? 'Verification needs syncing'
                          : _verificationTitle(isVerified, status, isLoading),
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasUntrackableStatus
                          ? 'Open the verification portal so we can reconnect your application number.'
                          : _verificationSubtitle(isVerified, status),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (hasTrackableApplication) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        verification!.applicationNumber!,
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!isVerified) ...<Widget>[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: isLoading ? null : onOpenPortal,
              icon: Icon(PhosphorIcons.arrowSquareOut),
              label: Text(
                status == 'more_info_requested'
                    ? 'Update application'
                    : hasTrackableApplication
                        ? 'Track application'
                        : 'Open verification portal',
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _verificationTitle(bool isVerified, String? status, bool isLoading) {
    if (isVerified) return 'Verified artisan';
    if (isLoading) return 'Checking verification';
    switch (status) {
      case 'pending':
        return 'Application pending';
      case 'under_review':
        return 'Under review';
      case 'more_info_requested':
        return 'More information needed';
      case 'rejected':
        return 'Verification not approved';
      default:
        return 'Get verified';
    }
  }

  String _verificationSubtitle(bool isVerified, String? status) {
    if (isVerified) return 'Clients will see your verified badge on your profile.';
    switch (status) {
      case 'pending':
        return 'Your application was received and is waiting for review.';
      case 'under_review':
        return 'The verification team is reviewing your documents.';
      case 'more_info_requested':
        return 'Open the portal to provide the requested information.';
      case 'rejected':
        return 'Open the portal to review the decision or submit updated details.';
      default:
        return 'Submit your documents to earn the official worker badge.';
    }
  }
}

class _RemoteProfileScaffold extends StatelessWidget {
  const _RemoteProfileScaffold({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CustomAppBar(
        title: 'Profile',
        showBackButton: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ProfileService.instance.getProfileById(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  userMessageFor(
                    snapshot.error ?? Exception('Profile unavailable'),
                    fallback: 'Could not load this profile.',
                  ),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge,
                ),
              ),
            );
          }

          final profile = UserProfileViewData.fromJson(snapshot.data!);
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _ProfileHero(profile: profile),
                  const SizedBox(height: 20),
                  if (profile.locationLabel != null &&
                      profile.locationLabel!.isNotEmpty) ...<Widget>[
                    ProfileSectionCard(
                      title: 'Location',
                      child: _InfoRow(
                        icon: PhosphorIcons.mapPin,
                        label: profile.locationLabel!,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  ProfileSectionCard(
                    title: 'Contact',
                    child: profile.phone != null
                        ? _InfoRow(
                            icon: PhosphorIcons.phone,
                            label: profile.phone!,
                          )
                        : Text('No phone added yet.', style: AppTypography.bodyMedium),
                  ),
                  const SizedBox(height: 14),
                  ProfileSectionCard(
                    title: 'About',
                    child: Text(
                      profile.bio ?? 'No bio yet.',
                      style: AppTypography.bodyLarge
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  if (profile.isWorker && profile.skills.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    ProfileSectionCard(
                      title: 'Skills & trades',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.skills
                            .map(
                              (String skill) => Chip(
                                label: Text(skill),
                                backgroundColor: AppColors.surfaceDim,
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final UserProfileViewData profile;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ArtisanLogoPanel(
                imageUrl: profile.avatarUrl,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                  Stack(
                    children: <Widget>[
                      ArtisanLogoAvatar(
                        imageUrl: profile.avatarUrl,
                        size: 104,
                      ),
                      if (profile.isVerified)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.success,
                            child: Icon(
                              PhosphorIcons.sealCheck,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    profile.fullName,
                    style: AppTypography.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      profile.isWorker ? 'Artisan' : 'Client',
                      style: AppTypography.labelCaps.copyWith(color: AppColors.primary),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: AppTypography.displayMedium.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.bodyMedium),
      ],
    );
  }
}
