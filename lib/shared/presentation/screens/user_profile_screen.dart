import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/profile_section_card.dart';
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
  });

  static const String routeName = '/shared/profile';

  /// When true, user is inside worker shell — Settings live on another tab.
  final bool embedInShell;
  final VoidCallback? onOpenWorkerEarnings;
  final VoidCallback? onOpenWorkerStats;
  final VoidCallback? onOpenWorkerHistory;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final ProfileArgs? args =
        ModalRoute.of(context)?.settings.arguments as ProfileArgs?;
    final UserProfileViewData profile = SharedUserContext.resolveProfile(args);
    final bool isOwnProfile = SharedUserContext.isOwnProfile(args?.userId);
    final bool isWorkerView = profile.isWorker;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: isOwnProfile ? 'My Profile' : 'Profile',
        showBackButton: !widget.embedInShell,
        actions: <Widget>[
          if (isOwnProfile)
            IconButton(
              onPressed: () => Navigator.pushNamed(context, EditProfileScreen.routeName).then((_) => setState(() {})),
              icon: Icon(PhosphorIcons.pencilSimple(), color: AppColors.primary),
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
                    icon: PhosphorIcons.mapPin(),
                    label: profile.locationLabel!,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              ProfileSectionCard(
                title: 'Contact',
                child: profile.phone != null
                    ? _InfoRow(
                        icon: PhosphorIcons.phone(),
                        label: profile.phone!,
                      )
                    : Text('No phone added yet.', style: AppTextStyles.bodyMd),
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
              if (isWorkerView) ...<Widget>[
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
                      style: AppTextStyles.bodyLg,
                    ),
                  ),
                ],
                if (profile.experienceBand != null) ...<Widget>[
                  const SizedBox(height: 14),
                  ProfileSectionCard(
                    title: 'Experience',
                    child: Text(
                      profile.experienceBand!,
                      style: AppTextStyles.bodyLg,
                    ),
                  ),
                ],
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
                if (isOwnProfile &&
                    (widget.onOpenWorkerEarnings != null ||
                        widget.onOpenWorkerStats != null ||
                        widget.onOpenWorkerHistory != null)) ...<Widget>[
                  const SizedBox(height: 14),
                  ProfileSectionCard(
                    title: 'Worker dashboard',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        if (widget.onOpenWorkerEarnings != null)
                          OutlinedButton.icon(
                            onPressed: widget.onOpenWorkerEarnings,
                            icon: Icon(PhosphorIcons.wallet()),
                            label: const Text('Earnings'),
                          ),
                        if (widget.onOpenWorkerStats != null)
                          OutlinedButton.icon(
                            onPressed: widget.onOpenWorkerStats,
                            icon: Icon(PhosphorIcons.chartLineUp()),
                            label: const Text('Stats'),
                          ),
                        if (widget.onOpenWorkerHistory != null)
                          OutlinedButton.icon(
                            onPressed: widget.onOpenWorkerHistory,
                            icon: Icon(PhosphorIcons.clockCounterClockwise()),
                            label: const Text('History'),
                          ),
                      ],
                    ),
                  ),
                ],
              ] else if (profile.totalJobs != null) ...<Widget>[
                const SizedBox(height: 14),
                ProfileSectionCard(
                  title: 'Activity',
                  child: _StatBlock(
                    label: 'Jobs posted',
                    value: '${profile.totalJobs}',
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (isOwnProfile) ...<Widget>[
                GradientButton(
                  label: 'Edit Profile',
                  onPressed: () => Navigator.pushNamed(
                    context,
                    EditProfileScreen.routeName,
                  ).then((_) => setState(() {})),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    SettingsScreen.routeName,
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
              if (profile.avatarUrl != null)
                CircleAvatar(
                  radius: 52,
                  backgroundImage: profile.avatarUrl!.startsWith('http')
                      ? NetworkImage(profile.avatarUrl!) as ImageProvider
                      : FileImage(File(profile.avatarUrl!)),
                  backgroundColor: AppColors.surfaceDim,
                )
              else
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.surfaceDim,
                  child: Text(
                    profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                    style: AppTextStyles.displayMd
                        .copyWith(color: AppColors.primary, fontSize: 32),
                  ),
                ),
              if (profile.isVerified)
                Positioned(bottom: 0, right: 0, child: CircleAvatar(radius: 14, backgroundColor: AppColors.success, child: Icon(PhosphorIcons.sealCheck(), color: Colors.white, size: 16),
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
