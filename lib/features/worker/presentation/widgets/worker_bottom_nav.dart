import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:artisans_app/core/theme/index.dart';

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
        color: AppColors.surface,
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
              _NavItem(
                icon: PhosphorIcons.compass,
                label: 'EXPLORE',
                tab: WorkerNavTab.explore,
                current: currentTab,
                onTap: onTabSelected,
              ),
              _NavItem(
                icon: PhosphorIcons.calendar,
                label: 'BOOKINGS',
                tab: WorkerNavTab.bookings,
                current: currentTab,
                onTap: onTabSelected,
              ),
              _NavItem(
                icon: PhosphorIcons.chatCircle,
                label: 'MESSAGES',
                tab: WorkerNavTab.messages,
                current: currentTab,
                onTap: onTabSelected,
              ),
              _NavItem(
                icon: PhosphorIcons.user,
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
                color: AppColors.primaryFixed.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
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
