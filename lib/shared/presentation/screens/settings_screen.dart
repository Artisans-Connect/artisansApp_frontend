import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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

  void _logout() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to use Artisans.'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.instance.signOut();
              SharedUserContext.session.reset();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                SignInScreen.routeName,
                (Route<dynamic> route) => false,
              );
              AppToast.showSuccess(context, 'Signed out.');
            },
            child: const Text('Log out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
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
                    activeColor: AppColors.primary,
                    onChanged: (bool value) {
                      setModalState(() => _pushEnabled = value);
                      setState(() => _pushEnabled = value);
                    },
                  ),
                  if (!_isWorker)
                    SwitchListTile(
                      title: const Text('Email updates'),
                      value: _emailUpdates,
                      activeColor: AppColors.primary,
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
                      'Artisans',
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
          onTap: () =>
              Navigator.pushNamed(context, EditProfileScreen.routeName),
          borderRadius: BorderRadius.circular(24),
          child: _ClientSettingsHero(
            onEdit: () =>
                Navigator.pushNamed(context, EditProfileScreen.routeName),
          ),
        ),
        const SizedBox(height: 20),
        _LegalAndSupportGroup(
          onPrivacy: () => _showStub('Privacy Policy'),
          onTerms: () => _showStub('Terms of Service'),
          onHelp: () => _showStub('Help Center'),
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
              icon: PhosphorIcons.bell(),
              title: 'Notification preferences',
              onTap: _openNotificationPrefs,
            ),
            SettingsTile(
              icon: PhosphorIcons.database(),
              title: 'Low data mode',
              trailing: Switch(
                value: _lowDataMode,
                activeColor: AppColors.primary,
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
  });

  final VoidCallback onPrivacy;
  final VoidCallback onTerms;
  final VoidCallback onHelp;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline.withOpacity(0.35)),
          ),
          child: Column(
            children: <Widget>[
              SettingsTile(
                icon: PhosphorIcons.shieldCheck(),
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: onPrivacy,
              ),
              SettingsTile(
                icon: PhosphorIcons.fileText(),
                title: 'Terms of Service',
                subtitle: 'Rules of the Artisans platform',
                onTap: onTerms,
              ),
              SettingsTile(
                icon: PhosphorIcons.question(),
                title: 'Help Center',
                subtitle: 'Support and documentation',
                onTap: onHelp,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline.withOpacity(0.35)),
          ),
          child: SettingsTile(
            icon: PhosphorIcons.signOut(),
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
              'Manage your Artisans experience',
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
              color: AppColors.primary.withOpacity(0.12),
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
              Icon(PhosphorIcons.wrench(), color: AppColors.primary, size: 32),
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
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: <Widget>[
          Icon(PhosphorIcons.star(), color: AppColors.primary, size: 36),
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
                  'You are an Artisans Elite member. Enjoy exclusive benefits.',
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
          'ARTISANS',
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
