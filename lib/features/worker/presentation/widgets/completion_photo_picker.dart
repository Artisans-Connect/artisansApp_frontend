import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
        Text('ADD PHOTOS', style: AppTypography.labelCaps),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _PhotoSlot(filled: true, icon: PhosphorIcons.wrench()),
            const SizedBox(width: AppSpacing.sm),
            _PhotoSlot(dashed: true),
            const SizedBox(width: AppSpacing.sm),
            _PhotoSlot(dashed: true),
            const SizedBox(width: AppSpacing.sm),
            _PhotoSlot(add: true),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(
              PhosphorIcons.cloud(),
              size: 16,
              color: AppColors.outline,
            ),
            const SizedBox(width: 6),
            Text(
              'Photos will sync when online',
              style: AppTypography.bodyMd.copyWith(fontSize: 12),
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
                ? AppColors.primary
                : filled
                    ? AppColors.surfaceContainer
                    : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: dashed
                ? Border.all(
                    color: AppColors.outlineVariant,
                    style: BorderStyle.solid,
                    width: 1.5,
                  )
                : null,
          ),
          child: add
              ? Icon(PhosphorIcons.plus(), color: AppColors.onPrimary, size: 28)
              : Icon(
                  icon ?? PhosphorIcons.image(),
                  color: AppColors.outline.withOpacity(0.5),
                ),
        ),
      ),
    );
  }
}
