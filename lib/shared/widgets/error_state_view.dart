import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'gradient_button.dart';

/// Full-area error UI with optional retry — for list/detail fetch failures.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.message,
    this.onRetry,
    this.title = 'Something went wrong',
    this.compact = false,
  });

  final String message;
  final String title;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.cloud_off_outlined,
          size: compact ? 48 : 64,
          color: AppColors.outline,
        ),
        SizedBox(height: compact ? 12 : 16),
        Text(
          title,
          style: AppTextStyles.displayMd.copyWith(fontSize: compact ? 18 : 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLg.copyWith(color: AppColors.textSecondary),
        ),
        if (onRetry != null) ...<Widget>[
          SizedBox(height: compact ? 16 : 24),
          SizedBox(
            width: compact ? 160 : 200,
            child: GradientButton(
              label: 'Try again',
              onPressed: onRetry,
            ),
          ),
        ],
      ],
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 24 : 32),
        child: content,
      ),
    );
  }
}
