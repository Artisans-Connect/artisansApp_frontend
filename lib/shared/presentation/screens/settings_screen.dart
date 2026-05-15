import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../widgets/settings_group_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/shared/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _emailUpdates = false;

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
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                SignInScreen.routeName,
                (Route<dynamic> route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Logout is stubbed for this UI phase.')),
              );
            },
            child:
                const Text('Log out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        ),
        title: Text('Settings',
            style: AppTextStyles.displayMd.copyWith(fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingsGroup(
              title: 'Notifications',
              children: <Widget>[
                SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push notifications',
                  trailing: Switch(
                    value: _pushEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (bool value) =>
                        setState(() => _pushEnabled = value),
                  ),
                  showDivider: true,
                ),
                SettingsTile(
                  icon: Icons.mail_outline,
                  title: 'Email updates',
                  trailing: Switch(
                    value: _emailUpdates,
                    activeColor: AppColors.primary,
                    onChanged: (bool value) =>
                        setState(() => _emailUpdates = value),
                  ),
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SettingsGroup(
              title: 'Legal',
              children: <Widget>[
                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _showStub(context, 'Privacy Policy'),
                ),
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => _showStub(context, 'Terms of Service'),
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SettingsGroup(
              title: 'Account',
              children: <Widget>[
                SettingsTile(
                  icon: Icons.logout,
                  title: 'Log out',
                  titleColor: AppColors.error,
                  onTap: _logout,
                  trailing: const SizedBox.shrink(),
                  showDivider: false,
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Artisans · Kumasi, Ghana',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd,
            ),
          ],
        ),
      ),
    );
  }

  void _showStub(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title will open here in a future release.')),
    );
  }
}
