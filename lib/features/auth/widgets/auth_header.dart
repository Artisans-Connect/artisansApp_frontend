import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: AppTextStyles.displayMd),
        const SizedBox(height: 8),
        Text(subtitle, style: AppTextStyles.bodyMd),
      ],
    );
  }
}
