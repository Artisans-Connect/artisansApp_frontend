import 'package:flutter/material.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';

class ReferencePhotosRow extends StatelessWidget {
  const ReferencePhotosRow({
    super.key,
    required this.labels,
  });

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: WorkerSpacing.sm),
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            decoration: BoxDecoration(
              color: WorkerColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: WorkerColors.outlineVariant.withOpacity(0.4),
              ),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(8),
            child: Text(
              labels[index],
              style: WorkerTextStyles.bodyMd.copyWith(
                color: WorkerColors.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}
