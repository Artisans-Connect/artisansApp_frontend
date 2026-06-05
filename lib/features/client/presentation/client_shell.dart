import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/presentation/screens/messages_list_screen.dart';
import '../../../shared/presentation/screens/user_profile_screen.dart';
import 'navigation/client_shell_scope.dart';
import 'screens/booking_history_screen.dart';
import 'screens/client_home_screen.dart';

enum ClientNavTab { home, bookings, messages, profile }

class ClientShell extends StatefulWidget {
  const ClientShell({super.key, this.initialTab = ClientNavTab.home});

  static const String routeName = '/client-shell';

  final ClientNavTab initialTab;

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  late ClientNavTab _currentTab;
  int _bookingsRefreshSignal = 0;
  int _messagesRefreshSignal = 0;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  void _selectTab(ClientNavTab tab) {
    setState(() {
      _currentTab = tab;
      if (tab == ClientNavTab.bookings) {
        _bookingsRefreshSignal++;
      } else if (tab == ClientNavTab.messages) {
        _messagesRefreshSignal++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClientShellScope(
      selectTab: _selectTab,
      child: Scaffold(
        body: IndexedStack(
          index: _currentTab.index,
          children: <Widget>[
            const ClientHomeScreen(),
            BookingHistoryScreen(
              embedInShell: true,
              refreshSignal: _bookingsRefreshSignal,
            ),
            MessagesListScreen(
              embedInShell: true,
              refreshSignal: _messagesRefreshSignal,
            ),
            const UserProfileScreen(embedInShell: true),
          ],
        ),
        bottomNavigationBar: _ClientBottomNav(
          currentTab: _currentTab,
          onTabSelected: _selectTab,
        ),
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
            color: Colors.black.withValues(alpha: 0.06),
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
                icon: PhosphorIcons.house,
                activeIcon: PhosphorIcons.house,
                label: 'HOME',
                tab: ClientNavTab.home,
                current: currentTab,
                onTap: onTabSelected,
              ),
              _ClientNavItem(
                icon: PhosphorIcons.calendar,
                activeIcon: PhosphorIcons.calendar,
                label: 'BOOKINGS',
                tab: ClientNavTab.bookings,
                current: currentTab,
                onTap: onTabSelected,
              ),
              _ClientNavItem(
                icon: PhosphorIcons.chatCircle,
                activeIcon: PhosphorIcons.chatCircle,
                label: 'MESSAGES',
                tab: ClientNavTab.messages,
                current: currentTab,
                onTap: onTabSelected,
              ),
              _ClientNavItem(
                icon: PhosphorIcons.user,
                activeIcon: PhosphorIcons.user,
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
                color: AppColors.primary.withValues(alpha: 0.08),
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
