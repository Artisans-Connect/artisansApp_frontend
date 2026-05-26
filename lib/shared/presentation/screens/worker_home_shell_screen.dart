import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'job_receipt_screen.dart';
import 'messages_list_screen.dart';
import 'settings_screen.dart';
import 'user_profile_screen.dart';

/// Post-onboarding worker shell with bottom navigation (UI stub).
class WorkerHomeShellScreen extends StatefulWidget {
  const WorkerHomeShellScreen({super.key});

  static const String routeName = '/shared/worker-home';

  @override
  State<WorkerHomeShellScreen> createState() => _WorkerHomeShellScreenState();
}

class _WorkerHomeShellScreenState extends State<WorkerHomeShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const _WorkerDashboardTab(),
      const MessagesListScreen(embedInShell: true),
      const UserProfileScreen(embedInShell: true),
      const SettingsScreen(embedInShell: true),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) => setState(() => _index = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _WorkerDashboardTab extends StatelessWidget {
  const _WorkerDashboardTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Dashboard',
            style: AppTextStyles.displayMd.copyWith(fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Recent jobs',
                style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _JobCard(
              title: 'Leaking kitchen sink',
              subtitle: 'Completed · Adum',
              onTap: () => Navigator.pushNamed(
                context,
                JobReceiptScreen.routeName,
              ),
            ),
            const SizedBox(height: 12),
            _JobCard(
              title: 'Electrical outlet repair',
              subtitle: 'Completed · Bantama',
              onTap: () => Navigator.pushNamed(
                context,
                JobReceiptScreen.routeName,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              const CircleAvatar(
                backgroundColor: AppColors.surfaceDim,
                child: Icon(Icons.receipt_long, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title,
                        style: AppTextStyles.bodyLg
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.bodyMd),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
