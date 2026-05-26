import 'package:flutter/material.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';

class CompletionPhotoPicker extends StatelessWidget {
  const CompletionPhotoPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ADD PHOTOS', style: WorkerTextStyles.labelCaps),
        const SizedBox(height: WorkerSpacing.sm),
        Row(
          children: [
            _PhotoSlot(filled: true, icon: Icons.handyman_outlined),
            const SizedBox(width: WorkerSpacing.sm),
            _PhotoSlot(dashed: true),
            const SizedBox(width: WorkerSpacing.sm),
            _PhotoSlot(dashed: true),
            const SizedBox(width: WorkerSpacing.sm),
            _PhotoSlot(add: true),
          ],
        ),
        const SizedBox(height: WorkerSpacing.sm),
        Row(
          children: [
            Icon(
              Icons.cloud_outlined,
              size: 16,
              color: WorkerColors.outline,
            ),
            const SizedBox(width: 6),
            Text(
              'Photos will sync when online',
              style: WorkerTextStyles.bodyMd.copyWith(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    this.filled = false,
    this.dashed = false,
    this.add = false,
    this.icon,
  });

  final bool filled;
  final bool dashed;
  final bool add;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: add
                ? WorkerColors.primary
                : filled
                    ? WorkerColors.surfaceContainer
                    : WorkerColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: dashed
                ? Border.all(
                    color: WorkerColors.outlineVariant,
                    style: BorderStyle.solid,
                    width: 1.5,
                  )
                : null,
          ),
          child: add
              ? const Icon(Icons.add, color: WorkerColors.onPrimary, size: 28)
              : Icon(
                  icon ?? Icons.image_outlined,
                  color: WorkerColors.outline.withOpacity(0.5),
                ),
        ),
      ),
    );
  }
}
