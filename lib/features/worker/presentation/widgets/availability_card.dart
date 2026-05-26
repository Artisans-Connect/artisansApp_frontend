import 'package:flutter/material.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';

class AvailabilityCard extends StatelessWidget {
  const AvailabilityCard({
    super.key,
    required this.isAvailable,
    required this.onChanged,
  });

  final bool isAvailable;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WorkerSpacing.md),
      decoration: BoxDecoration(
        color: WorkerColors.surface,
        borderRadius: BorderRadius.circular(WorkerColors.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available for work',
                  style: WorkerTextStyles.titleMd.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'When ON, you receive job requests.',
                  style: WorkerTextStyles.bodyMd,
                ),
              ],
            ),
          ),
          Switch(
            value: isAvailable,
            onChanged: onChanged,
            activeColor: WorkerColors.success,
          ),
        ],
      ),
    );
  }
}
