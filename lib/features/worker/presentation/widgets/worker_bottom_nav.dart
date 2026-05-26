import 'package:flutter/material.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_text_styles.dart';

enum WorkerNavTab { explore, bookings, messages, profile }

class WorkerBottomNav extends StatelessWidget {
  const WorkerBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final WorkerNavTab currentTab;
  final ValueChanged<WorkerNavTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WorkerColors.surface,
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
              _NavItem(
                icon: Icons.explore_outlined,
                label: 'EXPLORE',
                tab: WorkerNavTab.explore,
                current: currentTab,
                onTap: onTabSelected,
              ),
              _NavItem(
                icon: Icons.calendar_month_outlined,
                label: 'BOOKINGS',
                tab: WorkerNavTab.bookings,
                current: currentTab,
                onTap: onTabSelected,
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'MESSAGES',
                tab: WorkerNavTab.messages,
                current: currentTab,
                onTap: onTabSelected,
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'PROFILE',
                tab: WorkerNavTab.profile,
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.tab,
    required this.current,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final WorkerNavTab tab;
  final WorkerNavTab current;
  final ValueChanged<WorkerNavTab> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = current == tab;

    return InkWell(
      onTap: () => onTap(tab),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: WorkerColors.primaryFixed.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? WorkerColors.primary
                  : WorkerColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: WorkerTextStyles.badge.copyWith(
                color: isActive
                    ? WorkerColors.primary
                    : WorkerColors.onSurfaceVariant,
                fontSize: 9,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
