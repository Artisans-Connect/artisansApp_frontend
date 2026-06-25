import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/models/user_profile_view.dart';
import '../../../models/onboarding_session.dart';
import '../../../widgets/role_option_card.dart';

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
            subtitle: 'Find skilled professionals for your next project.',
            icon: PhosphorIcons.desktop,
            isSelected: session.isClient,
            onTap: () => onRoleSelected(UserRole.client),
          ),
          const SizedBox(height: 18),
          RoleOptionCard(
            title: 'I offer services',
            subtitle: 'Showcase your skills and find new clients.',
            icon: PhosphorIcons.briefcase,
            isSelected: session.isWorker,
            onTap: () => onRoleSelected(UserRole.worker),
          ),
        ],
      ),
    );
  }
}
