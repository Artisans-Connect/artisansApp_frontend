import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/platform_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/models/picked_media.dart';
import '../../../../shared/widgets/picked_media_image.dart';
import '../models/client_job_draft.dart';
import '../models/job_post_wizard_step.dart';
import '../widgets/job_post_wizard_scaffold.dart';

/// Merged step 3: Title + Description + Photo upload.
class JobPostDetailsScreen extends StatefulWidget {
  const JobPostDetailsScreen({super.key, this.jobData});

  final Map<String, dynamic>? jobData;

  @override
  State<JobPostDetailsScreen> createState() => _JobPostDetailsScreenState();
}

class _JobPostDetailsScreenState extends State<JobPostDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late ClientJobDraft _draft;
  final ImagePicker _picker = ImagePicker();
  final List<PickedMedia> _localPhotos = <PickedMedia>[];
  final List<String> _uploadedUrls = <String>[];
  bool _isUploadingPhoto = false;
  static const int _maxPhotos = 5;
  static const int _minDescriptionLength = 20;
  final int _maxTitleLength = 80;
  final int _maxDescriptionLength = 2000;

  List<String> get _suggestions {
    final String subcat = _draft.displaySubcategory;
    final String cat = _draft.displayCategory;

    if (subcat.isNotEmpty) {
      return <String>[
        'Fix $subcat',
        'Install or replace $subcat',
        'Emergency $subcat repair',
      ];
    }

    return <String>[
      'General $cat repair',
      'Emergency $cat service',
      'Standard $cat maintenance',
    ];
  }

  @override
  void initState() {
    super.initState();
    _draft = ClientJobDraft.fromMap(widget.jobData);
    _titleController = TextEditingController(text: _draft.title ?? '');
    _descriptionController =
        TextEditingController(text: _draft.description ?? '');
    // Restore already-uploaded URLs from draft
    final existingUrls = _draft.photoUrls;
    if (existingUrls.isNotEmpty) {
      _uploadedUrls.addAll(existingUrls);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _titleController.text.trim().length >= 3 &&
      _descriptionController.text.trim().length >= _minDescriptionLength;

  int get _descriptionLength => _descriptionController.text.trim().length;

  Future<void> _pickPhoto(ImageSource source) async {
    if (_localPhotos.length + _uploadedUrls.length >= _maxPhotos) {
      AppToast.showInfo(context, 'Maximum $_maxPhotos photos allowed.');
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;

    final PickedMedia media = await PickedMedia.fromXFile(image);
    setState(() {
      _localPhotos.add(media);
      _isUploadingPhoto = true;
    });

    try {
      final String? url =
          await StorageService.instance.uploadJobPhoto(media);
      if (!mounted) return;
      if (url != null) {
        setState(() {
          _uploadedUrls.add(url);
          _isUploadingPhoto = false;
        });
      } else {
        setState(() {
          _localPhotos.remove(media);
          _isUploadingPhoto = false;
        });
        if (mounted) {
          AppToast.showError(context, 'Upload failed', fallback: 'Could not upload photo.');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localPhotos.remove(media);
        _isUploadingPhoto = false;
      });
      AppToast.showError(context, e, fallback: 'Could not upload photo.');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      if (index < _localPhotos.length) {
        _localPhotos.removeAt(index);
      }
      if (index < _uploadedUrls.length) {
        _uploadedUrls.removeAt(index);
      }
    });
  }

  void _showPhotoSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading:
                    Icon(PhosphorIcons.images, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              if (PlatformService.supportsCamera)
                ListTile(
                  leading:
                      Icon(PhosphorIcons.camera, color: AppColors.primary),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickPhoto(ImageSource.camera);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _continue() {
    _draft.merge(<String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'photoUrls': List<String>.from(_uploadedUrls),
    });
    Navigator.pushNamed(
      context,
      AppRoutes.jobPostLocationSchedule,
      arguments: _draft.toMap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalPhotos = _uploadedUrls.length;

    return JobPostWizardScaffold(
      step: JobPostWizardStep.details,
      headline: 'Describe your job',
      primaryLabel: 'Next',
      primaryEnabled: _canContinue,
      onPrimary: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Help artisans understand exactly what you need.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          // ── Title ─────────────────────────────────────────────
          const SizedBox(height: AppSpacing.lg),
          Text('Job title', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _titleController,
            maxLength: _maxTitleLength,
            style: AppTypography.bodyLarge,
            decoration: InputDecoration(
              hintText: 'e.g. Fix leaking kitchen faucet',
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _suggestions.map((String s) {
              return ActionChip(
                label: Text(s, style: AppTypography.bodySmall),
                onPressed: () {
                  _titleController.text = s;
                  setState(() {});
                },
              );
            }).toList(),
          ),

          // ── Description ───────────────────────────────────────
          const SizedBox(height: AppSpacing.lg),
          Text('Description', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _descriptionController,
            maxLength: _maxDescriptionLength,
            maxLines: 5,
            decoration: InputDecoration(
              hintText:
                  'What should the artisan do? Include scope, access details, and any deadlines.',
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _descriptionLength < _minDescriptionLength
                      ? 'Add at least $_minDescriptionLength characters so artisans understand the work.'
                      : 'Description length looks good.',
                  style: AppTypography.bodySmall.copyWith(
                    color: _descriptionLength < _minDescriptionLength
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '$_descriptionLength/$_maxDescriptionLength',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // ── Photos ────────────────────────────────────────────
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text('Photos', style: AppTypography.labelLarge),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '($totalPhotos / $_maxPhotos)',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add photos to help artisans assess the job (optional).',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              // Show uploaded photos
              for (int i = 0; i < _localPhotos.length; i++)
                _PhotoThumb(
                  media: _localPhotos[i],
                  onRemove: () => _removePhoto(i),
                ),
              // Add button
              if (totalPhotos < _maxPhotos)
                InkWell(
                  onTap: _isUploadingPhoto ? null : _showPhotoSourcePicker,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMedium),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.outlineVariant),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    child: _isUploadingPhoto
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            PhosphorIcons.cameraPlus,
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
            ],
          ),

          // ── Tips ──────────────────────────────────────────────
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(PhosphorIcons.lightbulb,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Tips for a great job post',
                        style: AppTypography.labelMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _TipItem(
                  icon: PhosphorIcons.checkCircle,
                  color: AppColors.success,
                  text: 'Be specific: "Repair oak dining table leg"',
                ),
                const SizedBox(height: 4),
                _TipItem(
                  icon: PhosphorIcons.xCircle,
                  color: AppColors.error,
                  text: 'Avoid vague: "URGENT HELP NEEDED!!!"',
                ),
                const SizedBox(height: 4),
                _TipItem(
                  icon: PhosphorIcons.camera,
                  color: AppColors.primary,
                  text: 'Photos help artisans give better estimates',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.media, required this.onRemove});

  final PickedMedia media;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          child: PickedMediaImage(
            media: media,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
