import 'package:flutter/material.dart';
import '../../../../../core/services/payment_service.dart';
import '../../../../../core/services/negotiation_service.dart';
import '../../../../../shared/models/negotiation.dart';
import '../../../../../shared/widgets/negotiation_chat_sheet.dart';
import '../../../../../shared/widgets/app_toast.dart';
import '../../../../../core/theme/design_tokens.dart';

class SettlementDetailsCard extends StatefulWidget {
  final Map<String, dynamic> job;
  final VoidCallback? onSettled;

  const SettlementDetailsCard({super.key, required this.job, this.onSettled});

  @override
  State<SettlementDetailsCard> createState() => _SettlementDetailsCardState();
}

class _SettlementDetailsCardState extends State<SettlementDetailsCard> {
  bool _loading = true;
  String? _error;
  double _escrowHeld = 0.0;
  double _grossAmount = 0.0;
  double _outstandingBalance = 0.0;
  double _platformFee = 0.0;
  double _workerPayout = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchSettlementDetails();
  }

  Future<void> _fetchSettlementDetails() async {
    final String jobId = widget.job['id']?.toString() ?? '';
    if (jobId.isEmpty) return;

    try {
      final res = await PaymentService.instance.calculateSettlement(jobId);
      if (!mounted) return;
      setState(() {
        _escrowHeld = double.tryParse(res['escrow_held']?.toString() ?? '0') ?? 0.0;
        _grossAmount = double.tryParse(res['gross_amount']?.toString() ?? '0') ?? 0.0;
        _outstandingBalance = double.tryParse(res['outstanding_balance']?.toString() ?? '0') ?? 0.0;
        _platformFee = double.tryParse(res['platform_fee']?.toString() ?? '0') ?? 0.0;
        _workerPayout = double.tryParse(res['worker_payout']?.toString() ?? '0') ?? 0.0;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load settlement calculations.';
        _loading = false;
      });
    }
  }

  Future<void> _negotiateFinalPrice() async {
    final String jobId = widget.job['id']?.toString() ?? '';
    if (jobId.isEmpty) return;

    setState(() => _loading = true);
    try {
      final List<Negotiation> negs = await NegotiationService.instance.getJobNegotiations(jobId);
      Negotiation? targetNeg = negs.cast<Negotiation?>().firstWhere(
        (n) => n?.type == NegotiationType.completionAdjustment,
        orElse: () => null,
      );

      if (targetNeg == null) {
        targetNeg = await NegotiationService.instance.createNegotiation(
          jobId: jobId,
          type: 'completion_adjustment',
          initialAmount: _grossAmount,
          description: 'Final completion settlement bargaining',
        );
      }

      setState(() => _loading = false);
      if (!mounted) return;

      NegotiationChatSheet.show(
        context,
        negotiation: targetNeg,
        onStatusChanged: () {
          _fetchSettlementDetails();
          if (widget.onSettled != null) widget.onSettled!();
        },
      );
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not start negotiation.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_error!, style: const TextStyle(color: DesignTokens.error)),
        ),
      );
    }

    Widget rowItem(String label, double amount, {bool isTotal = false, bool isDeduction = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: isTotal ? 15 : 13,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
                color: isTotal ? DesignTokens.textPrimary : DesignTokens.textSecondary,
              ),
            ),
            Text(
              '${isDeduction ? "-" : ""} GHS ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: isTotal ? 15 : 13,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
                color: isDeduction 
                    ? Colors.red 
                    : isTotal 
                        ? DesignTokens.primary 
                        : DesignTokens.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: DesignTokens.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Settlement Details',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: DesignTokens.borderSubtle, height: 1),
          const SizedBox(height: 8),
          rowItem('Gross Total Work Value', _grossAmount),
          if (_escrowHeld > 0)
            rowItem('Upfront Escrow Deposit Paid', _escrowHeld, isDeduction: true),
          const SizedBox(height: 8),
          const Divider(color: DesignTokens.borderSubtle, height: 1),
          const SizedBox(height: 8),
          rowItem('Outstanding Balance to Pay', _outstandingBalance, isTotal: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _negotiateFinalPrice,
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Bargain Final Price'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
