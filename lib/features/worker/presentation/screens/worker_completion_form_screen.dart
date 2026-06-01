import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/services.dart';
import '../models/mock_worker_job.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';
import '../widgets/completion_photo_picker.dart';
import '../widgets/gradient_button.dart';
import '../widgets/job_detail_card.dart';
import 'worker_completion_success_screen.dart';

class WorkerCompletionFormScreen extends StatefulWidget {
  const WorkerCompletionFormScreen({
    super.key,
    required this.job,
    required this.onCompletionSubmitted,
  });

  final MockWorkerJob job;
  final VoidCallback onCompletionSubmitted;

  @override
  State<WorkerCompletionFormScreen> createState() =>
      _WorkerCompletionFormScreenState();
}

class _WorkerCompletionFormScreenState
    extends State<WorkerCompletionFormScreen> {
  final _hoursController = TextEditingController();
  final _materialsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _hoursController.dispose();
    _materialsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_hoursController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter time spent')),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => WorkerCompletionSuccessScreen(
          job: widget.job,
          onDone: widget.onCompletionSubmitted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(), size: 20),
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Complete Booking',
          style: AppTypography.titleMd.copyWith(color: AppColors.primary),
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
                  Text('Booking Summary', style: AppTypography.titleMd),
                  const SizedBox(height: 8),
                  Text(
                    'Confirm your work details to close this booking and notify the client.',
                    style: AppTypography.bodyMd,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('TIME SPENT (HOURS)', style: AppTypography.labelCaps),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _hoursController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('e.g., 3.5'),
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
            const CompletionPhotoPicker(),
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
                style: AppTypography.bodyLg.copyWith(
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
      hintStyle: AppTypography.bodyMd,
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
