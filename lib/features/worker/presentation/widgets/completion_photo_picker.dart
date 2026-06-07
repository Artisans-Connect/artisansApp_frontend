import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:artisans_app/core/theme/index.dart';

class CompletionPhotoPicker extends StatelessWidget {
  const CompletionPhotoPicker({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    this.isBusy = false,
  });

  final List<File> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final int slotCount = photos.length < 4 ? photos.length + 1 : photos.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ADD PHOTOS', style: AppTypography.labelCaps),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List.generate(slotCount.clamp(1, 4).toInt(), (int index) {
            final bool hasPhoto = index < photos.length;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == slotCount - 1 ? 0 : AppSpacing.sm,
                ),
                child: _PhotoSlot(
                  file: hasPhoto ? photos[index] : null,
                  add: !hasPhoto,
                  isBusy: isBusy,
                  onTap: hasPhoto ? () => onRemove(index) : onAdd,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(
              PhosphorIcons.cloud,
              size: 16,
              color: AppColors.outline,
            ),
            const SizedBox(width: 6),
            Text(
              'Photos will sync when online',
              style: AppTypography.bodyMedium.copyWith(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    this.add = false,
    this.file,
    this.onTap,
    this.isBusy = false,
  });

  final bool add;
  final File? file;
  final VoidCallback? onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: add
                ? AppColors.primary
                : file != null
                    ? AppColors.surfaceContainer
                    : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: file == null && !add
                ? Border.all(
                    color: AppColors.outlineVariant,
                    style: BorderStyle.solid,
                    width: 1.5,
                  )
                : null,
          ),
          child: file != null
              ? Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(file!, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            Colors.black.withValues(alpha: 0.55),
                        child: Icon(
                          PhosphorIcons.x,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                )
              : Icon(
                  add ? PhosphorIcons.plus : PhosphorIcons.image,
                  color: add
                      ? AppColors.onPrimary
                      : AppColors.outline.withValues(alpha: 0.5),
                  size: add ? 28 : 24,
                ),
        ),
      ),
    );
  }
}
