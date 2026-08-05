import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/index.dart';
import '../state/worker_session_state.dart';

class WorkerPhaseStepper extends StatelessWidget {
  const WorkerPhaseStepper({
    super.key,
    required this.currentPhase,
  });

  final WorkerJobPhase currentPhase;

  int _getStepIndex() {
    switch (currentPhase) {
      case WorkerJobPhase.accepted:
      case WorkerJobPhase.onTheWay:
        return 0; // Step 1: En Route
      case WorkerJobPhase.arrived:
        return 1; // Step 2: Arrived
      case WorkerJobPhase.inProgress:
        return 2; // Step 3: In Progress
      case WorkerJobPhase.pendingApproval:
      case WorkerJobPhase.terminationRequested:
        return 3; // Step 4: Done / Review
      case WorkerJobPhase.none:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int activeStep = _getStepIndex();
    final List<_StepData> steps = const <_StepData>[
      _StepData(label: 'En Route', icon: PhosphorIcons.navigationArrow),
      _StepData(label: 'Arrived', icon: PhosphorIcons.mapPin),
      _StepData(label: 'In Progress', icon: PhosphorIcons.timer),
      _StepData(label: 'Review', icon: PhosphorIcons.checkCircle),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: DesignTokens.borderSubtle),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: DesignTokens.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List<Widget>.generate(steps.length * 2 - 1, (int index) {
          if (index.isOdd) {
            final int stepBefore = index ~/ 2;
            final bool isDone = stepBefore < activeStep;
            return Expanded(
              child: Container(
                height: 2.5,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isDone ? DesignTokens.successGreen : DesignTokens.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          } else {
            final int stepIdx = index ~/ 2;
            final _StepData step = steps[stepIdx];
            final bool isCurrent = stepIdx == activeStep;
            final bool isDone = stepIdx < activeStep;

            Color iconBg = DesignTokens.surfaceHighlight;
            Color iconColor = DesignTokens.textMuted;
            if (isDone) {
              iconBg = DesignTokens.successGreen.withValues(alpha: 0.15);
              iconColor = DesignTokens.successGreen;
            } else if (isCurrent) {
              iconBg = DesignTokens.primary;
              iconColor = Colors.white;
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isCurrent ? 32 : 28,
                  height: isCurrent ? 32 : 28,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? <BoxShadow>[
                            BoxShadow(
                              color: DesignTokens.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      isDone ? PhosphorIcons.checkBold : step.icon,
                      size: isCurrent ? 16 : 14,
                      color: iconColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent
                        ? DesignTokens.primary
                        : (isDone ? DesignTokens.textPrimary : DesignTokens.textMuted),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}

class _StepData {
  const _StepData({required this.label, required this.icon});
  final String label;
  final IconData icon;
}
