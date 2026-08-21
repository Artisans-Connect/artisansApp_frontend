import 'package:flutter/material.dart';

import 'package:artisans_app/core/theme/design_tokens.dart';

// ---------------------------------------------------------------------------
// ProgressTimeline – vertical step indicator for job progress
// ---------------------------------------------------------------------------

class ProgressTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> steps;
  final int currentStep;
  final Animation<double> pulseAnimation;

  const ProgressTimeline({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      child: Column(
        children: List.generate(steps.length, (int index) {
          final Map<String, dynamic> step = steps[index];
          final bool isCompleted = index <= currentStep;
          final bool isCurrent = index == currentStep;
          final bool isUpcoming = index > currentStep;

          return Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Step node
                  AnimatedBuilder(
                    animation: pulseAnimation,
                    builder: (_, child) {
                      final double pulse = isCurrent
                          ? (1.0 + pulseAnimation.value * 0.12)
                          : 1.0;
                      return Transform.scale(scale: pulse, child: child);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? const LinearGradient(
                                colors: [DesignTokens.primary, DesignTokens.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isUpcoming
                            ? const Color(0xFFF0EBE5)
                            : null,
                        shape: BoxShape.circle,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                    color: DesignTokens.primary.withValues(alpha: 0.30),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4))
                              ]
                            : isCompleted
                                ? [
                                    BoxShadow(
                                        color: DesignTokens.primary.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3))
                                  ]
                                : null,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: isCompleted
                            ? Colors.white
                            : DesignTokens.textSecondary.withValues(alpha: 0.45),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          step['title'] as String,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 14,
                            fontWeight: isCurrent
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isCurrent
                                ? DesignTokens.primary
                                : isCompleted
                                    ? DesignTokens.textPrimary
                                    : DesignTokens.textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step['description'] as String,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 12,
                            color: isUpcoming
                                ? DesignTokens.textSecondary.withValues(alpha: 0.35)
                                : DesignTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: DesignTokens.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (index < currentStep)
                    const Icon(Icons.check_rounded,
                        color: DesignTokens.primary, size: 18),
                ],
              ),
              if (index < steps.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 0, bottom: 0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 2,
                        height: 38,
                        child: isCompleted && index < currentStep
                            ? Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [DesignTokens.primary, DesignTokens.primaryDark],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFE8E0D8),
                              ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
