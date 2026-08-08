import 'package:flutter/material.dart';
import '../../../../../core/session/app_user_session.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../shared/utils/greeting_utils.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  String _firstName() {
    final String fullName = AppUserSession.instance.currentUser?.fullName ?? '';
    final List<String> parts = fullName.trim().split(' ');
    return parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final String firstName = _firstName();
    final String greeting = GreetingUtils.getGreeting();
    final String subtitle = GreetingUtils.getWorkerSubtitle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          firstName.isNotEmpty ? '$greeting, $firstName' : greeting,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: DesignTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 14,
            color: DesignTokens.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
