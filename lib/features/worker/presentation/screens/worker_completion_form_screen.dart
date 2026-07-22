import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/models/picked_media.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../models/worker_job.dart';
import '../utils/worker_job_mapper.dart';
import '../widgets/completion_photo_picker.dart';
import '../widgets/gradient_button.dart';
import '../widgets/job_detail_card.dart';
import 'worker_completion_success_screen.dart';
import '../../../../shared/widgets/custom_back_button.dart';

class WorkerCompletionFormScreen extends StatefulWidget {
  const WorkerCompletionFormScreen({
    super.key,
    required this.job,
    required this.onCompletionSubmitted,
  });
  final WorkerJob job;
  final VoidCallback onCompletionSubmitted;
  @override
  State<WorkerCompletionFormScreen> createState() =>
      _WorkerCompletionFormScreenState();
}
class _WorkerCompletionFormScreenState
    extends State<WorkerCompletionFormScreen> {
  final _proposedAmountController = TextEditingController();
  final _materialsController = TextEditingController();
  final _notesController = TextEditingController();
  final JobsService _jobsService = JobsService();
  final ImagePicker _picker = ImagePicker();
  final List<PickedMedia> _photos = <PickedMedia>[];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final double? amount =
        widget.job.grossAmount ?? widget.job.applicationTotalQuote;
    if (amount != null && amount > 0) {
      _proposedAmountController.text = amount.toStringAsFixed(2);
    }
    if ((widget.job.completionMaterials ?? '').isNotEmpty) {
      _materialsController.text = widget.job.completionMaterials!;
    }
    if ((widget.job.completionNotes ?? '').isNotEmpty) {
      _notesController.text = widget.job.completionNotes!;
    }
  }

  @override
  void dispose() {
    _proposedAmountController.dispose();
    _materialsController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  Future<void> _submit() async {
    if (_isSubmitting) return;
    final double? proposedAmount =
        double.tryParse(_proposedAmountController.text.trim());
    if (proposedAmount == null || proposedAmount <= 0) {
      AppToast.showError(context, 'Enter a valid proposed amount.');
      return;
    }
    await HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);
    try {
      final List<String> photoUrls = <String>[];
      for (final PickedMedia file in _photos) {
        final String? url =
            await StorageService.instance.uploadCompletionPhoto(file);
        if (url != null) photoUrls.add(url);
      }
      final dynamic updated = await _jobsService.completeJob(
        widget.job.id,
        body: <String, dynamic>{
          'proposed_amount': proposedAmount,
          if (_materialsController.text.trim().isNotEmpty)
            'materials_used': _materialsController.text.trim(),
          if (_notesController.text.trim().isNotEmpty)
            'notes': _notesController.text.trim(),
          'photo_urls': photoUrls,
        },
      );
      if (!mounted) return;
      final WorkerJob successJob = updated is Map<String, dynamic>
          ? workerJobFromApi(updated)
          : widget.job;
      setState(() => _isSubmitting = false);
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => WorkerCompletionSuccessScreen(
            job: successJob,
            onDone: widget.onCompletionSubmitted,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppToast.showError(context, e, fallback: 'Could not complete job.');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'Complete Booking',
          style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            JobDetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Summary', style: AppTypography.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Confirm your work details to close this booking and notify the client.',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('PROPOSED AMOUNT TO CHARGE', style: AppTypography.labelCaps),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _proposedAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('e.g., 150.00'),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'You can edit this amount until the client approves completion. Time spent is recorded automatically from when the job started.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('MATERIALS USED (OPTIONAL)', style: AppTypography.labelCaps),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _materialsController,
              maxLines: 3,
              decoration: _inputDecoration(
                'List any parts or supplies provided...',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            CompletionPhotoPicker(
              photos: _photos,
              isBusy: _isSubmitting,
              onAdd: _pickPhoto,
              onRemove: (int index) {
                if (_isSubmitting) return;
                setState(() => _photos.removeAt(index));
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('NOTES FOR CLIENT (OPTIONAL)', style: AppTypography.labelCaps),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: _inputDecoration(
                'Describe the work completed or maintenance tips...',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              label: 'Submit & Complete',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel Completion',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMedium,
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _pickPhoto() async {
    if (_isSubmitting || _photos.length >= 4) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;
    final PickedMedia media = await PickedMedia.fromXFile(image);
    if (!mounted) return;
    setState(() => _photos.add(media));
  }
}
