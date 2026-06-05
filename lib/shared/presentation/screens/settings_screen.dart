import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/navigation/auth_navigation.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/session/app_user_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../utils/shared_user_context.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/settings_group_tile.dart';
import 'edit_profile_screen.dart';

/// Shared settings — client layout (53) vs worker layout (65) on same route.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.embedInShell = false});

  static const String routeName = '/shared/settings';

  final bool embedInShell;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _emailUpdates = false;
  bool _lowDataMode = false;

  bool get _isWorker => SharedUserContext.isWorker;

  Future<void> _logout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to use ArtisansConnect.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await AuthService.instance.signOut();
    SharedUserContext.session.reset();
    if (!mounted) return;
    AppToast.showSuccess(context, 'Signed out.');
    await Navigator.pushNamedAndRemoveUntil(
      context,
      SignInScreen.routeName,
      (_) => false,
    );
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

  void _becomeWorker() {
    unawaited(Navigator.pushNamed(
      context,
      RoleSelectionScreen.routeName,
      arguments: <String, dynamic>{'isBecomingWorker': true},
    ));
  }

  VoidCallback? get _onSwitchOrBecomeWorker {
    if (SharedUserContext.isViewingAsWorker) {
      return () => _switchView('client');
    }
    if (SharedUserContext.canSwitchToWorker) {
      return () => _switchView('worker');
    }
    if (!SharedUserContext.isWorkerCapable) {
      return _becomeWorker;
    }
    return null;
  }

  String get _switchViewLabel {
    if (SharedUserContext.isViewingAsWorker) return 'Switch to Client View';
    if (SharedUserContext.canSwitchToWorker) return 'Switch to Worker View';
    return 'Become a Worker';
  }

  String get _switchViewSubtitle {
    if (SharedUserContext.isViewingAsWorker) {
      return 'Return to the client dashboard';
    }
    if (SharedUserContext.canSwitchToWorker) {
      return 'Open the worker dashboard';
    }
    return 'Offer services and find jobs';
  }

  void _showStub(String title) {
    AppToast.showInfo(context, '$title — coming soon');
  }

  void _openNotificationPrefs() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('Notification preferences',
                      style: AppTextStyles.displayMd.copyWith(fontSize: 22)),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('Push notifications'),
                    value: _pushEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (bool value) {
                      setModalState(() => _pushEnabled = value);
                      setState(() => _pushEnabled = value);
                    },
                  ),
                  if (!_isWorker)
                    SwitchListTile(
                      title: const Text('Email updates'),
                      value: _emailUpdates,
                      activeThumbColor: AppColors.primary,
                      onChanged: (bool value) {
                        setModalState(() => _emailUpdates = value);
                        setState(() => _emailUpdates = value);
                      },
                    ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: widget.embedInShell
          ? null
          : CustomAppBar(
              title: _isWorker ? 'Settings' : 'Settings & Info',
              showBackButton: true,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Text(
                      'ArtisansConnect',
                      style: AppTextStyles.bodyLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: _isWorker ? _buildWorkerBody() : _buildClientBody(),
      ),
    );
  }

  Widget _buildClientBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InkWell(
          onTap: () => unawaited(
            Navigator.pushNamed(context, EditProfileScreen.routeName),
          ),
          borderRadius: BorderRadius.circular(24),
          child: _ClientSettingsHero(
            onEdit: () => unawaited(
              Navigator.pushNamed(context, EditProfileScreen.routeName),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _LegalAndSupportGroup(
          onPrivacy: () => _showStub('Privacy Policy'),
          onTerms: () => _showStub('Terms of Service'),
          onHelp: () => _showStub('Help Center'),
          onSwitchView: _onSwitchOrBecomeWorker,
          switchViewLabel: _switchViewLabel,
          switchViewSubtitle: _switchViewSubtitle,
          onLogout: _logout,
        ),
        const SizedBox(height: 20),
        const _CommunityPromoCard(),
        const SizedBox(height: 16),
        const _PremiumStatusCard(),
        const SizedBox(height: 28),
        const _SettingsFooter(),
      ],
    );
  }

  Widget _buildWorkerBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Account Preferences',
          style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Manage your account security and notification settings.',
          style: AppTextStyles.bodyMd,
        ),
        const SizedBox(height: 20),
        SettingsGroup(
          title: '',
          children: <Widget>[
            SettingsTile(
              icon: PhosphorIcons.bell,
              title: 'Notification preferences',
              onTap: _openNotificationPrefs,
            ),
            SettingsTile(
              icon: PhosphorIcons.database,
              title: 'Low data mode',
              trailing: Switch(
                value: _lowDataMode,
                activeThumbColor: AppColors.primary,
                onChanged: (bool value) => setState(() => _lowDataMode = value),
              ),
              showDivider: false,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _LegalAndSupportGroup(
          onPrivacy: () => _showStub('Privacy Policy'),
          onTerms: () => _showStub('Terms of Service'),
          onHelp: () => _showStub('Help Center'),
          onSwitchView: _onSwitchOrBecomeWorker,
          switchViewLabel: _switchViewLabel,
          switchViewSubtitle: _switchViewSubtitle,
          onLogout: _logout,
        ),
        const SizedBox(height: 28),
        const _SettingsFooter(),
      ],
    );
  }
}

class _LegalAndSupportGroup extends StatelessWidget {
  const _LegalAndSupportGroup({
    required this.onPrivacy,
    required this.onTerms,
    required this.onHelp,
    required this.onLogout,
    this.onSwitchView,
    this.switchViewLabel,
    this.switchViewSubtitle,
  });

  final VoidCallback onPrivacy;
  final VoidCallback onTerms;
  final VoidCallback onHelp;
  final VoidCallback onLogout;
  final VoidCallback? onSwitchView;
  final String? switchViewLabel;
  final String? switchViewSubtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.35)),
          ),
          child: Column(
            children: <Widget>[
              SettingsTile(
                icon: PhosphorIcons.shieldCheck,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: onPrivacy,
              ),
              SettingsTile(
                icon: PhosphorIcons.fileText,
                title: 'Terms of Service',
                subtitle: 'Rules of the ArtisansConnect platform',
                onTap: onTerms,
              ),
              SettingsTile(
                icon: PhosphorIcons.question,
                title: 'Help Center',
                subtitle: 'Support and documentation',
                onTap: onHelp,
                showDivider: false,
              ),
            ],
          ),
        ),
        if (onSwitchView != null && switchViewLabel != null) ...<Widget>[
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.35)),
            ),
            child: SettingsTile(
              icon: PhosphorIcons.arrowsLeftRight,
              title: switchViewLabel!,
              subtitle: switchViewSubtitle,
              onTap: onSwitchView,
              showDivider: false,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.35)),
          ),
          child: SettingsTile(
            icon: PhosphorIcons.signOut,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            titleColor: AppColors.error,
            onTap: onLogout,
            trailing: const SizedBox.shrink(),
            showDivider: false,
          ),
        ),
      ],
    );
  }
}

class _ClientSettingsHero extends StatelessWidget {
  const _ClientSettingsHero({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.primary,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              'Profile Settings',
              style: AppTextStyles.displayMd
                  .copyWith(color: Colors.white, fontSize: 26),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage your ArtisansConnect experience',
              style: AppTextStyles.bodyLg.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
              ),
              child: const Text('Edit profile →'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPromoCard extends StatelessWidget {
  const _CommunityPromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'COMMUNITY',
              style: AppTextStyles.labelCaps.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(PhosphorIcons.wrench, color: AppColors.primary, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Join our Artisan Network',
                      style: AppTextStyles.bodyLg
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Elite craftsmanship on demand',
                      style: AppTextStyles.bodyMd,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Worker onboarding opens from sign-up.')),
              );
            },
            child: const Text('CONNECT NOW'),
          ),
        ],
      ),
    );
  }
}

class _PremiumStatusCard extends StatelessWidget {
  const _PremiumStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Icon(PhosphorIcons.star, color: AppColors.primary, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Premium Member',
                  style: AppTextStyles.bodyLg
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'You are an ArtisansConnect Elite member. Enjoy exclusive benefits.',
                  style: AppTextStyles.bodyMd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsFooter extends StatelessWidget {
  const _SettingsFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'ARTISANSCONNECT',
          style: AppTextStyles.labelCaps.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text('v1.4.0 · Kumasi, Ghana', style: AppTextStyles.bodyMd),
      ],
    );
  }
}
