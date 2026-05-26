import 'package:flutter/material.dart';
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
  const WorkerCompletionFormScreen({super.key, required this.job});

  final MockWorkerJob job;

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
        builder: (_) => WorkerCompletionSuccessScreen(job: widget.job),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorkerColors.background,
      appBar: AppBar(
        backgroundColor: WorkerColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: WorkerColors.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Complete Job',
          style: WorkerTextStyles.titleMd.copyWith(color: WorkerColors.primary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          WorkerSpacing.gutter,
          0,
          WorkerSpacing.gutter,
          WorkerSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            JobDetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Job Summary', style: WorkerTextStyles.titleMd),
                  const SizedBox(height: 8),
                  Text(
                    'Confirm your work details to finalize the invoice and notify the client.',
                    style: WorkerTextStyles.bodyMd,
                  ),
                ],
              ),
            ),
            const SizedBox(height: WorkerSpacing.lg),
            Text('TIME SPENT (HOURS)', style: WorkerTextStyles.labelCaps),
            const SizedBox(height: WorkerSpacing.sm),
            TextField(
              controller: _hoursController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('e.g., 3.5'),
            ),
            const SizedBox(height: WorkerSpacing.lg),
            Text('MATERIALS USED (OPTIONAL)', style: WorkerTextStyles.labelCaps),
            const SizedBox(height: WorkerSpacing.sm),
            TextField(
              controller: _materialsController,
              maxLines: 3,
              decoration: _inputDecoration(
                'List any parts or supplies provided...',
              ),
            ),
            const SizedBox(height: WorkerSpacing.lg),
            const CompletionPhotoPicker(),
            const SizedBox(height: WorkerSpacing.lg),
            Text('NOTES FOR CLIENT (OPTIONAL)', style: WorkerTextStyles.labelCaps),
            const SizedBox(height: WorkerSpacing.sm),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: _inputDecoration(
                'Describe the work completed or maintenance tips...',
              ),
            ),
            const SizedBox(height: WorkerSpacing.xl),
            GradientButton(
              label: 'Submit & Complete',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel Completion',
                style: WorkerTextStyles.bodyLg.copyWith(
                  color: WorkerColors.primary,
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
      hintStyle: WorkerTextStyles.bodyMd,
      filled: true,
      fillColor: WorkerColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
