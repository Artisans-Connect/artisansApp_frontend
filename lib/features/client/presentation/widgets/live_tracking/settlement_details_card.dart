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
  double _initialEscrow = 0.0;
  double _totalExtraCharges = 0.0;
  List<Map<String, dynamic>> _extraChargeList = <Map<String, dynamic>>[];
  double _grossAmount = 0.0;
  double _outstandingBalance = 0.0;

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
      final rawExtras = res['extra_charges'] as List?;
      setState(() {
        _escrowHeld = double.tryParse(res['escrow_held']?.toString() ?? '0') ?? 0.0;
        _initialEscrow = double.tryParse(res['initial_escrow']?.toString() ?? '0') ?? 0.0;
        _totalExtraCharges = double.tryParse(res['total_extra_charges']?.toString() ?? '0') ?? 0.0;
        _extraChargeList = rawExtras != null
            ? rawExtras.cast<Map<String, dynamic>>()
            : <Map<String, dynamic>>[];
        _grossAmount = double.tryParse(res['gross_amount']?.toString() ?? '0') ?? 0.0;
        _outstandingBalance = double.tryParse(res['outstanding_balance']?.toString() ?? '0') ?? 0.0;
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
          rowItem('Original Agreed Escrow', _initialEscrow > 0 ? _initialEscrow : _grossAmount),
          if (_totalExtraCharges > 0) ...<Widget>[
            rowItem('Additional Extra Charges (+)', _totalExtraCharges),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DesignTokens.warmSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DesignTokens.warmBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Row(
                    children: <Widget>[
                      Icon(Icons.info_outline, size: 14, color: DesignTokens.accentWarm),
                      SizedBox(width: 6),
                      Text(
                        'Extra Charge Reason(s)',
                        style: TextStyle(fontFamily: 'Satoshi', fontSize: 11, fontWeight: FontWeight.bold, color: DesignTokens.accentWarm),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (_extraChargeList.isEmpty)
                    const Text('Additional materials & labor requested during work', style: TextStyle(fontFamily: 'Satoshi', fontSize: 12, color: DesignTokens.textPrimary))
                  else
                    ..._extraChargeList.map(
                      (extra) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '• ${extra['description']} (+GHS ${(double.tryParse(extra['amount']?.toString() ?? '0') ?? 0).toStringAsFixed(2)})',
                          style: const TextStyle(fontFamily: 'Satoshi', fontSize: 12, color: DesignTokens.textPrimary, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          rowItem('Gross Total Work Value', _grossAmount, isTotal: true),
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
