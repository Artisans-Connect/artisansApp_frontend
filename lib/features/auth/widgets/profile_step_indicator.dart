import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProfileStepIndicator extends StatelessWidget {
  const ProfileStepIndicator({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(2, (int index) {
        final bool active = index < currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: active ? AppColors.primary : AppColors.outline,
            ),
          ),
        );
      }),
    );
  }
}
