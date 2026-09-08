import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/session/app_user_session.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/shared/models/user_profile_view.dart';
import 'package:artisans_app/shared/models/onboarding_session.dart';
import 'package:artisans_app/features/auth/widgets/role_option_card.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({
    super.key,
    required this.session,
    required this.onRoleSelected,
  });

  final OnboardingSession session;
  final ValueChanged<UserRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    final AppUser? currentUser = AppUserSession.instance.currentUser;
    final bool isClientOccupied = currentUser != null;
    final bool isWorkerOccupied = currentUser?.hasWorkerProfile ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 14),
          Text(
            'How will you use\nCraftMatch?',
            textAlign: TextAlign.center,
            style: AppTypography.displayMedium.copyWith(fontSize: 50 * 0.78),
          ),
          const SizedBox(height: 10),
          Text(
            'Select your primary role to customize your\nexperience and connect with the right people.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: 24),
          RoleOptionCard(
            title: 'I need a worker',
            subtitle: isClientOccupied
                ? 'You already have an active Client profile.'
                : 'Find skilled professionals for your next project.',
            icon: PhosphorIcons.desktop,
            isSelected: isClientOccupied ? false : session.isClient,
            isDisabled: isClientOccupied,
            statusBadge: isClientOccupied ? 'Current Role' : null,
            onTap: () {
              if (!isClientOccupied) {
                onRoleSelected(UserRole.client);
              }
            },
          ),
          const SizedBox(height: 18),
          RoleOptionCard(
            title: 'I offer services',
            subtitle: isWorkerOccupied
                ? 'You are already registered as a worker.'
                : isClientOccupied
                    ? 'Expand your account to offer services and earn.'
                    : 'Showcase your skills and find new clients.',
            icon: PhosphorIcons.briefcase,
            isSelected: isWorkerOccupied ? false : session.isWorker,
            isDisabled: isWorkerOccupied,
            statusBadge: isWorkerOccupied
                ? 'Active Worker'
                : isClientOccupied
                    ? 'Available'
                    : null,
            onTap: () {
              if (!isWorkerOccupied) {
                onRoleSelected(UserRole.worker);
              }
            },
          ),
        ],
      ),
    );
  }
}
