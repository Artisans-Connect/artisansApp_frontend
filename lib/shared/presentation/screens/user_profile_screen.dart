import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/gradient_button.dart';
import '../../data/shared_stub_data.dart';
import '../../models/user_profile_view.dart';
import '../../widgets/profile_section_card.dart';
import '../navigation/shared_route_args.dart';
import 'settings_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  static const String routeName = '/shared/profile';

  UserProfileViewData _resolveProfile(ProfileArgs? args) {
    if (args == null || args.userId == SharedStubData.currentUserId) {
      return SharedStubData.currentUserProfile;
    }
    if (args.viewAsWorker || args.userId != SharedStubData.currentUserId) {
      return SharedStubData.sampleWorkerProfile;
    }
    return SharedStubData.currentUserProfile;
  }

  @override
  Widget build(BuildContext context) {
    final ProfileArgs? args =
        ModalRoute.of(context)?.settings.arguments as ProfileArgs?;
    final UserProfileViewData profile = _resolveProfile(args);
    final bool isOwnProfile = profile.id == SharedStubData.currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              _ProfileHero(profile: profile),
              const SizedBox(height: 20),
              ProfileSectionCard(
                title: 'Contact',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (profile.phone != null)
                      _InfoRow(
                          icon: Icons.phone_outlined, label: profile.phone!),
                    if (profile.phone == null)
                      Text('No phone added yet.', style: AppTextStyles.bodyMd),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ProfileSectionCard(
                title: 'About',
                child: Text(
                  profile.bio ?? 'No bio yet.',
                  style: AppTextStyles.bodyLg
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
              if (profile.isWorker) ...<Widget>[
                const SizedBox(height: 14),
                ProfileSectionCard(
                  title: 'Skills',
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
                      if (profile.totalJobs != null)
                        Expanded(
                          child: _StatBlock(
                            label: 'Jobs',
                            value: '${profile.totalJobs}',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (isOwnProfile) ...<Widget>[
                GradientButton(
                  label: 'Edit Profile',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Edit profile is stubbed for this UI phase.')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, SettingsScreen.routeName),
                  child: const Text('Account Settings'),
                ),
              ] else
                GradientButton(
                  label: 'Message',
                  onPressed: () => Navigator.maybePop(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final UserProfileViewData profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.surfaceDim,
                child: Text(
                  profile.fullName.isNotEmpty ? profile.fullName[0] : '?',
                  style: AppTextStyles.displayMd
                      .copyWith(color: AppColors.primary),
                ),
              ),
              if (profile.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.success,
                    child: const Icon(Icons.verified,
                        color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName,
            style: AppTextStyles.displayMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              profile.isWorker ? 'Artisan' : 'Client',
              style: AppTextStyles.labelCaps.copyWith(color: AppColors.primary),
            ),
          ),
        ],
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
            style: AppTextStyles.bodyLg.copyWith(color: AppColors.textPrimary),
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
          style: AppTextStyles.displayMd.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodyMd),
      ],
    );
  }
}
