import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:artisans_app/core/theme/index.dart';
import 'package:artisans_app/shared/models/picked_media.dart';
import 'package:artisans_app/shared/widgets/picked_media_image.dart';

class CompletionPhotoPicker extends StatelessWidget {
  const CompletionPhotoPicker({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    this.isBusy = false,
  });

  final List<PickedMedia> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('WORK PHOTOS', style: AppTypography.labelCaps),
            ),
            Text(
              '${photos.length}/4',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Add clear photos of the finished work or materials used.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (photos.isNotEmpty) ...[
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) => _PhotoThumb(
                file: photos[index],
                isBusy: isBusy,
                onRemove: () => onRemove(index),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        OutlinedButton.icon(
          onPressed: isBusy || photos.length >= 4 ? null : onAdd,
          icon: Icon(PhosphorIcons.cameraPlus),
          label: Text(
            photos.isEmpty ? 'Add work photos' : 'Add another photo',
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.45)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
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

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({
    required this.file,
    required this.onRemove,
    this.isBusy = false,
  });

  final PickedMedia file;
  final VoidCallback onRemove;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: PickedMediaImage(media: file, fit: BoxFit.cover),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: Material(
              color: Colors.black.withValues(alpha: 0.58),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: isBusy ? null : onRemove,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    PhosphorIcons.x,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
