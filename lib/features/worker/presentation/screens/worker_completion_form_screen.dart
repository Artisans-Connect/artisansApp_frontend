import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/services/negotiation_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/models/negotiation.dart';
import '../../../../shared/models/picked_media.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/negotiation_chat_sheet.dart';
import '../../../../shared/widgets/custom_back_button.dart';
import '../models/worker_job.dart';
import '../utils/worker_job_mapper.dart';
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

  bool _loadingSettlement = true;
  double _initialEscrow = 0.0;
  double _acceptedExtraCharges = 0.0;
  List<Map<String, dynamic>> _pendingExtraCharges = <Map<String, dynamic>>[];
  Negotiation? _openNegotiation;

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
    _fetchSettlementAndNegotiations();
  }

  Future<void> _fetchSettlementAndNegotiations() async {
    try {
      final res = await PaymentService.instance.calculateSettlement(widget.job.id);
      final List<Negotiation> negs = await NegotiationService.instance.getJobNegotiations(widget.job.id);
      final Negotiation? openNeg = negs.cast<Negotiation?>().firstWhere(
        (n) => n?.status == NegotiationStatus.open,
        orElse: () => null,
      );

      final double grossAmount = double.tryParse(res['gross_amount']?.toString() ?? '0') ?? 0.0;
      final double initialEscrow = double.tryParse(res['initial_escrow']?.toString() ?? '0') ?? 0.0;
      final double extraCharges = double.tryParse(res['total_extra_charges']?.toString() ?? '0') ?? 0.0;
      final rawPending = res['pending_extra_charges'] as List?;
      final List<Map<String, dynamic>> pendingList = rawPending != null
          ? rawPending.cast<Map<String, dynamic>>()
          : <Map<String, dynamic>>[];

      if (mounted) {
        setState(() {
          _initialEscrow = initialEscrow;
          _acceptedExtraCharges = extraCharges;
          _pendingExtraCharges = pendingList;
          _openNegotiation = openNeg;
          _loadingSettlement = false;

          // If grossAmount exists and includes extra charges, prefill text controller with gross total!
          if (grossAmount > 0) {
            _proposedAmountController.text = grossAmount.toStringAsFixed(2);
            _previewAmount = grossAmount;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingSettlement = false);
      }
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

  Widget _buildPendingAgreementBanner() {
    if (_loadingSettlement || (_pendingExtraCharges.isEmpty && _openNegotiation == null)) {
      return const SizedBox.shrink();
    }

    final double pendingAmt = _pendingExtraCharges.fold(
      0.0,
      (sum, item) => sum + (double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFB45309)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _pendingExtraCharges.isNotEmpty
                      ? '⚡ Pending Extra Charge Proposal (+GHS ${pendingAmt.toStringAsFixed(2)})'
                      : '⚡ Active Price Bargaining in Progress',
                  style: const TextStyle(fontFamily: 'Satoshi', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _pendingExtraCharges.isNotEmpty
                ? 'Your extra charge of GHS ${pendingAmt.toStringAsFixed(2)} is pending client acceptance. Click below to add it to your proposed total.'
                : 'There is an open price bargaining negotiation on this job. Click below to review with the client.',
            style: const TextStyle(fontFamily: 'Satoshi', fontSize: 12, color: DesignTokens.textPrimary),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              if (_pendingExtraCharges.isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final double currentInput = double.tryParse(_proposedAmountController.text.trim()) ?? (_initialEscrow + _acceptedExtraCharges);
                      final double newTotal = currentInput + pendingAmt;
                      setState(() {
                        _proposedAmountController.text = newTotal.toStringAsFixed(2);
                        _previewAmount = newTotal;
                      });
                      AppToast.showPayment(context, '⚡ Added +GHS ${pendingAmt.toStringAsFixed(2)} extra charge to proposed total: GHS ${newTotal.toStringAsFixed(2)}');
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 14, color: Colors.white),
                    label: Text(
                      'Include Extra (+GHS ${pendingAmt.toStringAsFixed(2)})',
                      style: const TextStyle(fontFamily: 'Satoshi', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              if (_pendingExtraCharges.isNotEmpty && _openNegotiation != null) const SizedBox(width: 8),
              if (_openNegotiation != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      NegotiationChatSheet.show(
                        context,
                        negotiation: _openNegotiation!,
                        onStatusChanged: _fetchSettlementAndNegotiations,
                      );
                    },
                    icon: const Icon(Icons.chat_outlined, size: 14),
                    label: const Text(
                      'Review Chat',
                      style: TextStyle(fontFamily: 'Satoshi', fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
            ],
          ),
        ],
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
            _buildPendingAgreementBanner(),
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
            _PayoutPreview(
              amount: _previewAmount,
              feeRate: _platformFeeRate,
              initialEscrow: _initialEscrow,
              acceptedExtraCharges: _acceptedExtraCharges,
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
    this.initialEscrow = 0.0,
    this.acceptedExtraCharges = 0.0,
  });

  final double? amount;
  final double feeRate;
  final double initialEscrow;
  final double acceptedExtraCharges;

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
          if (initialEscrow > 0 && acceptedExtraCharges > 0) ...[
            _PayoutRow(
              label: 'Original Base Escrow',
              value: _formatGhs(initialEscrow),
            ),
            const SizedBox(height: AppSpacing.xs),
            _PayoutRow(
              label: 'Approved Extra Charges (+)',
              value: _formatGhs(acceptedExtraCharges),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          _PayoutRow(
            label: 'Gross Amount sent to client',
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
