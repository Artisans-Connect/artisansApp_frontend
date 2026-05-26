import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Shared dot-style page/step indicator used across onboarding intro
/// screens and profile-completion steps.
///
/// The active dot renders as a wider pill; inactive dots render as small
/// circles.  Sizing and colors are intentionally hard-wired to design
/// tokens so every consumer looks identical.
class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    required this.totalDots,
    required this.activeIndex,
  });

  /// How many dots to render.
  final int totalDots;

  /// Zero-based index of the currently active dot.
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(totalDots, (int index) {
        final bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(right: index < totalDots - 1 ? 8 : 0),
          width: isActive ? 52 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
