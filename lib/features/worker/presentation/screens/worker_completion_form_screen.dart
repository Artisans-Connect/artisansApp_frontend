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
  static const double _platformFeeRate = 0.10;
  final _proposedAmountController = TextEditingController();
  final _materialsController = TextEditingController();
  final _notesController = TextEditingController();
  final JobsService _jobsService = JobsService();
  final ImagePicker _picker = ImagePicker();
  final List<PickedMedia> _photos = <PickedMedia>[];
  bool _isSubmitting = false;
  double? _previewAmount;

  @override
  void initState() {
    super.initState();
    final double? amount = widget.job.grossAmount ??
        widget.job.applicationTotalQuote ??
        _amountFromEstimateLabel(widget.job.estimatedBudgetLabel);
    if (amount != null && amount > 0) {
      _proposedAmountController.text = amount.toStringAsFixed(2);
    }
    _previewAmount = amount;
    _proposedAmountController.addListener(_updateAmountPreview);
    if ((widget.job.completionMaterials ?? '').isNotEmpty) {
      _materialsController.text = widget.job.completionMaterials!;
    }
    if ((widget.job.completionNotes ?? '').isNotEmpty) {
      _notesController.text = widget.job.completionNotes!;
    }
  }

  @override
  void dispose() {
    _proposedAmountController.removeListener(_updateAmountPreview);
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
            Text('FINAL AMOUNT FOR CLIENT APPROVAL', style: AppTypography.labelCaps),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _proposedAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('e.g., 150.00'),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Prefilled from your accepted quote when available, otherwise from the client estimate. You can still edit it before sending for client approval.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            _PayoutPreview(amount: _previewAmount, feeRate: _platformFeeRate),
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

  void _updateAmountPreview() {
    final double? amount =
        double.tryParse(_proposedAmountController.text.trim());
    if (amount == _previewAmount) return;
    setState(() => _previewAmount = amount);
  }

  double? _amountFromEstimateLabel(String? label) {
    if (label == null) return null;
    final RegExpMatch? match =
        RegExp(r'(\d+(?:\.\d+)?)').firstMatch(label.replaceAll(',', ''));
    return match == null ? null : double.tryParse(match.group(1)!);
  }
}

class _PayoutPreview extends StatelessWidget {
  const _PayoutPreview({
    required this.amount,
    required this.feeRate,
  });

  final double? amount;
  final double feeRate;

  @override
  Widget build(BuildContext context) {
    final double grossAmount = amount != null && amount! > 0 ? amount! : 0;
    final double platformFee =
        (grossAmount * feeRate * 100).roundToDouble() / 100;
    final double payout = grossAmount - platformFee;
    final bool hasAmount = grossAmount > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAYOUT PREVIEW',
            style: AppTypography.labelCaps.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PayoutRow(
            label: 'Amount sent to client',
            value: hasAmount ? _formatGhs(grossAmount) : '--',
          ),
          const SizedBox(height: AppSpacing.xs),
          _PayoutRow(
            label: 'Platform fee (${(feeRate * 100).toStringAsFixed(0)}%)',
            value: hasAmount ? '-${_formatGhs(platformFee)}' : '--',
          ),
          const Divider(height: AppSpacing.lg),
          _PayoutRow(
            label: 'Estimated payout',
            value: hasAmount ? _formatGhs(payout) : '--',
            isEmphasis: true,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This preview updates as you type. Final payout is confirmed after the client approves the completion.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatGhs(double value) => 'GHS ${value.toStringAsFixed(2)}';
}

class _PayoutRow extends StatelessWidget {
  const _PayoutRow({
    required this.label,
    required this.value,
    this.isEmphasis = false,
  });

  final String label;
  final String value;
  final bool isEmphasis;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = AppTypography.bodySmall.copyWith(
      color: isEmphasis ? AppColors.textPrimary : AppColors.textSecondary,
      fontWeight: isEmphasis ? FontWeight.w700 : FontWeight.w500,
    );
    final TextStyle valueStyle = AppTypography.bodyMedium.copyWith(
      color: isEmphasis ? AppColors.primary : AppColors.textPrimary,
      fontWeight: isEmphasis ? FontWeight.w800 : FontWeight.w600,
    );

    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        const SizedBox(width: AppSpacing.sm),
        Text(value, style: valueStyle),
      ],
    );
  }
}
