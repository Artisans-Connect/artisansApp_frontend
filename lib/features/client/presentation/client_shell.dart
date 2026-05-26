import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/presentation/screens/messages_list_screen.dart';
import '../../../shared/presentation/screens/user_profile_screen.dart';
import 'screens/booking_history_screen.dart';
import 'screens/client_home_screen.dart';

enum ClientNavTab { home, bookings, messages, profile }

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  static const String routeName = '/client-shell';

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  ClientNavTab _currentTab = ClientNavTab.home;

  final Map<ClientNavTab, Widget> _tabScreens = {
    ClientNavTab.home: const ClientHomeScreen(),
    ClientNavTab.bookings: const BookingHistoryScreen(embedInShell: true),
    ClientNavTab.messages: const MessagesListScreen(embedInShell: true),
    ClientNavTab.profile: const UserProfileScreen(embedInShell: true),
  };

  void _onTabSelected(ClientNavTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab.index,
        children: _tabScreens.values.toList(),
      ),
      bottomNavigationBar: _ClientBottomNav(
        currentTab: _currentTab,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}

class _ClientBottomNav extends StatelessWidget {
  const _ClientBottomNav({
    required this.currentTab,
    required this.onTabSelected,
  });

  final ClientNavTab currentTab;
  final ValueChanged<ClientNavTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ClientNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'HOME',
                tab: ClientNavTab.home,
                current: currentTab,
                onTap: onTabSelected,
              ),
              _ClientNavItem(
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month_rounded,
                label: 'BOOKINGS',
                tab: ClientNavTab.bookings,
                current: currentTab,
                onTap: onTabSelected,
              ),
              _ClientNavItem(
                icon: Icons.chat_bubble_outline_rounded,
                activeIcon: Icons.chat_bubble_rounded,
                label: 'MESSAGES',
                tab: ClientNavTab.messages,
                current: currentTab,
                onTap: onTabSelected,
              ),
              _ClientNavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'PROFILE',
                tab: ClientNavTab.profile,
                current: currentTab,
                onTap: onTabSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientNavItem extends StatelessWidget {
  const _ClientNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.tab,
    required this.current,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ClientNavTab tab;
  final ClientNavTab current;
  final ValueChanged<ClientNavTab> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = current == tab;

    return InkWell(
      onTap: () => onTap(tab),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                fontSize: 9,
                letterSpacing: 0.2,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
