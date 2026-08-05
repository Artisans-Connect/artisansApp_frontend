import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/navigation/auth_navigation.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/session/app_user_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../../features/client/presentation/navigation/client_navigation.dart';
import '../navigation/legal_navigation.dart';
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
  bool _isLoggingOut = false;
  bool _isDeleting = false;


  bool get _isWorker => SharedUserContext.isWorker;

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to use CraftMatch.'),
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
    setState(() => _isLoggingOut = true);
    try {
      await AuthService.instance.signOut();
      SharedUserContext.session.reset();
      if (!mounted) return;
      AppToast.showSuccess(context, 'Signed out.');
      await Navigator.pushNamedAndRemoveUntil(
        context,
        SignInScreen.routeName,
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not sign out.');
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  Future<void> _deleteAccount() async {
    if (_isDeleting) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        final TextEditingController controller = TextEditingController();
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            bool canDelete = controller.text.trim().toLowerCase() == 'delete my account';
            return AlertDialog(
              title: const Text('Delete your account?', style: TextStyle(color: AppColors.error)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'This action is permanent and cannot be undone. '
                    'All your profile data, jobs, reviews, messages, and uploaded files will be permanently deleted.',
                  ),
                  const SizedBox(height: 16),
                  const SelectableText(
                    'To confirm, please type "delete my account" below:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'delete my account',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String val) {
                      setDialogState(() {
                        canDelete = val.trim().toLowerCase() == 'delete my account';
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: canDelete ? () => Navigator.pop(ctx, true) : null,
                  child: Text(
                    'Delete permanently',
                    style: TextStyle(
                      color: canDelete ? AppColors.error : Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;
    setState(() => _isDeleting = true);
    try {
      await AuthService.instance.deleteAccount();
      SharedUserContext.session.reset();
      if (!mounted) return;
      AppToast.showSuccess(context, 'Your account has been deleted.');
      await Navigator.pushNamedAndRemoveUntil(
        context,
        SignInScreen.routeName,
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not delete account.');
    } finally {
      if (mounted) setState(() => _isDeleting = false);
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

  void _openPrivacyPolicy() {
    unawaited(LegalNavigation.openPrivacyPolicy(context));
  }

  void _openTermsOfService() {
    unawaited(LegalNavigation.openTermsOfService(context));
  }

  Future<void> _openHelpCenter() async {
    await ClientNavigation.callPhone(context, '0257243106');
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
                      style: AppTypography.displayMedium.copyWith(fontSize: 22)),
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
                      'CraftMatch',
                      style: AppTypography.bodyLarge.copyWith(
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
          onPrivacy: _openPrivacyPolicy,
          onTerms: _openTermsOfService,
          onHelp: _openHelpCenter,
          onSwitchView: _onSwitchOrBecomeWorker,
          switchViewLabel: _switchViewLabel,
          switchViewSubtitle: _switchViewSubtitle,
          onLogout: _logout,
          isLoggingOut: _isLoggingOut,
          onDeleteAccount: _deleteAccount,
          isDeleting: _isDeleting,
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
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Manage your account security and notification settings.',
          style: AppTypography.bodyMedium,
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
              trailing: const Switch(
                value: false,
                onChanged: null,
              ),
              showDivider: false,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _LegalAndSupportGroup(
          onPrivacy: _openPrivacyPolicy,
          onTerms: _openTermsOfService,
          onHelp: _openHelpCenter,
          onSwitchView: _onSwitchOrBecomeWorker,
          switchViewLabel: _switchViewLabel,
          switchViewSubtitle: _switchViewSubtitle,
          onLogout: _logout,
          isLoggingOut: _isLoggingOut,
          onDeleteAccount: _deleteAccount,
          isDeleting: _isDeleting,
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
    required this.isLoggingOut,
    required this.onDeleteAccount,
    required this.isDeleting,
    this.onSwitchView,
    this.switchViewLabel,
    this.switchViewSubtitle,
  });

  final VoidCallback onPrivacy;
  final VoidCallback onTerms;
  final VoidCallback onHelp;
  final VoidCallback onLogout;
  final bool isLoggingOut;
  final VoidCallback onDeleteAccount;
  final bool isDeleting;
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
                subtitle: 'Rules of the CraftMatch platform',
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
            icon: isLoggingOut ? PhosphorIcons.spinnerGap : PhosphorIcons.signOut,
            title: isLoggingOut ? 'Logging out...' : 'Logout',
            subtitle:
                isLoggingOut ? 'Please wait while we sign you out' : 'Sign out of your account',
            titleColor: AppColors.error,
            onTap: isLoggingOut ? null : onLogout,
            trailing: isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.error,
                    ),
                  )
                : const SizedBox.shrink(),
            showDivider: false,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.35)),
          ),
          child: SettingsTile(
            icon: isDeleting ? PhosphorIcons.spinnerGap : PhosphorIcons.trash,
            title: isDeleting ? 'Deleting account...' : 'Delete Account',
            subtitle: isDeleting
                ? 'Please wait while we delete your account'
                : 'Permanently delete your account and history',
            titleColor: AppColors.error,
            onTap: isDeleting ? null : onDeleteAccount,
            trailing: isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.error,
                    ),
                  )
                : const SizedBox.shrink(),
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
              style: AppTypography.displayMedium
                  .copyWith(color: Colors.white, fontSize: 26),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage your CraftMatch experience',
              style: AppTypography.bodyLarge.copyWith(color: Colors.white70),
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
              style: AppTypography.labelCaps.copyWith(
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
                      style: AppTypography.bodyLarge
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Elite craftsmanship on demand',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                  style: AppTypography.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'You are an CraftMatch Elite member. Enjoy exclusive benefits.',
                  style: AppTypography.bodyMedium,
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
          'CraftMatch',
          style: AppTypography.labelCaps.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text('v1.4.0 · Kumasi, Ghana', style: AppTypography.bodyMedium),
      ],
    );
  }
}
