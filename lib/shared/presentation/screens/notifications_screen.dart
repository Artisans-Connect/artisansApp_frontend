import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../widgets/custom_back_button.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.surfaceBase,
      appBar: AppBar(
        backgroundColor: DesignTokens.surfaceBase,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: DesignTokens.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 64, color: DesignTokens.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No new notifications',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: DesignTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up! Check back later.',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14,
                color: DesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
