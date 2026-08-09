import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../core/session/app_user_session.dart';
import '../../core/services/negotiation_service.dart';
import '../../core/services/negotiation_realtime_service.dart';
import '../../core/theme/index.dart';
import '../models/negotiation.dart';
import 'app_input.dart';
import 'app_loader.dart';
import 'app_toast.dart';
import 'gradient_button.dart';
import 'secondary_button.dart';

class NegotiationChatSheet extends StatefulWidget {
  const NegotiationChatSheet({
    super.key,
    required this.negotiation,
    this.onStatusChanged,
  });

  final Negotiation negotiation;
  final VoidCallback? onStatusChanged;

  @override
  State<NegotiationChatSheet> createState() => _NegotiationChatSheetState();

  static void show(
    BuildContext context, {
    required Negotiation negotiation,
    VoidCallback? onStatusChanged,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: NegotiationChatSheet(
            negotiation: negotiation,
            onStatusChanged: onStatusChanged,
          ),
        );
      },
    );
  }
}

class _NegotiationChatSheetState extends State<NegotiationChatSheet> {
  late Negotiation _currentNegotiation;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;
  bool _isCountering = false;

  final NegotiationRealtimeService _realtimeService = NegotiationRealtimeService();

  @override
  void initState() {
    super.initState();
    _currentNegotiation = widget.negotiation;
    _realtimeService.subscribeToNegotiation(
      _currentNegotiation.id,
      onUpdate: () {
        _refreshSilent();
      },
    );
  }

  @override
  void dispose() {
    _realtimeService.unsubscribe();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    try {
      final Negotiation updated = await NegotiationService.instance.getNegotiation(_currentNegotiation.id);
      setState(() {
        _currentNegotiation = updated;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) AppToast.showError(context, e, fallback: 'Failed to refresh.');
    }
  }

  Future<void> _refreshSilent() async {
    try {
      final Negotiation updated = await NegotiationService.instance.getNegotiation(_currentNegotiation.id);
      if (!mounted) return;
      setState(() {
        _currentNegotiation = updated;
      });
    } catch (_) {}
  }

  Future<void> _accept() async {
    setState(() => _isLoading = true);
    try {
      final Negotiation updated = await NegotiationService.instance.acceptNegotiation(_currentNegotiation.id);
      setState(() {
        _currentNegotiation = updated;
        _isLoading = false;
      });
      if (mounted) {
        AppToast.showPayment(context, '🤝 Offer Agreed! Price updated in job settlement.');
        widget.onStatusChanged?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) AppToast.showError(context, e, fallback: 'Failed to accept offer.');
    }
  }

  Future<void> _reject() async {
    final String? reason = await _showRejectReasonDialog();
    if (reason == null) return; // Cancelled dialog

    setState(() => _isLoading = true);
    try {
      final Negotiation updated = await NegotiationService.instance.rejectNegotiation(
        negotiationId: _currentNegotiation.id,
        reason: reason.trim().isEmpty ? null : reason.trim(),
      );
      setState(() {
        _currentNegotiation = updated;
        _isLoading = false;
      });
      if (mounted) {
        AppToast.showInfo(context, 'Bargain offer declined.');
        widget.onStatusChanged?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) AppToast.showError(context, e, fallback: 'Failed to reject offer.');
    }
  }

  Future<void> _counter() async {
    final String amountStr = _amountController.text.trim();
    if (amountStr.isEmpty) {
      AppToast.showInfo(context, 'Please enter counter amount');
      return;
    }
    final double? amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      AppToast.showInfo(context, 'Please enter a valid positive amount');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final String? note = _noteController.text.trim();
      final Negotiation updated = await NegotiationService.instance.proposeAmount(
        negotiationId: _currentNegotiation.id,
        amount: amount,
        note: note?.isEmpty == true ? null : note,
      );
      setState(() {
        _currentNegotiation = updated;
        _isLoading = false;
        _isCountering = false;
      });
      _amountController.clear();
      _noteController.clear();
      if (mounted) {
        AppToast.showPayment(context, '⚡ Counter-offer sent! Proposed: GH\u20B5 ${amount.toStringAsFixed(2)}');
        widget.onStatusChanged?.call();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) AppToast.showError(context, e, fallback: 'Failed to send counter-offer.');
    }
  }

  Future<String?> _showRejectReasonDialog() async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Decline Bargain Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Would you like to provide a reason for declining?'),
            const SizedBox(height: 12),
            AppInput(
              controller: controller,
              hint: 'Reason (optional)',
              maxLines: 2,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = AppUserSession.instance.currentUser?.id ?? '';
    final List<NegotiationRound> rounds = _currentNegotiation.rounds;
    final NegotiationRound? lastRound = rounds.isNotEmpty ? rounds.last : null;
    final bool isMyTurn = lastRound != null && lastRound.proposedBy != currentUserId;
    final bool isOpen = _currentNegotiation.status == NegotiationStatus.open;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _getNegotiationTitle(_currentNegotiation.type),
                      style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        _buildStatusBadge(_currentNegotiation.status),
                        const SizedBox(width: 8),
                        Text(
                          'Job #${_currentNegotiation.jobId.substring(0, 8)}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(PhosphorIcons.x, size: 24, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main body containing rounds or loader
          Expanded(
            child: _isLoading && rounds.isEmpty
                ? const Center(child: AppLoader())
                : RefreshIndicator(
                    onRefresh: _refresh,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: rounds.length,
                      itemBuilder: (BuildContext context, int index) {
                        final NegotiationRound round = rounds[index];
                        final bool isMine = round.proposedBy == currentUserId;

                        return _buildRoundBubble(round, isMine);
                      },
                    ),
                  ),
          ),

          const Divider(height: 1),

          // Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: _isLoading
                ? const Center(child: AppLoader())
                : _isCountering
                    ? _buildCounterForm()
                    : _buildActionBar(isOpen, isMyTurn, lastRound),
          ),
        ],
      ),
    );
  }

  String _getNegotiationTitle(NegotiationType type) {
    switch (type) {
      case NegotiationType.quote:
        return 'Bargain Quote';
      case NegotiationType.extraCharge:
        return 'Negotiate Extra Charge';
      case NegotiationType.completionAdjustment:
        return 'Adjust Final Bill';
    }
  }

  Widget _buildStatusBadge(NegotiationStatus status) {
    Color color = Colors.grey;
    String label = 'Open';
    switch (status) {
      case NegotiationStatus.open:
        color = Colors.blue;
        label = 'Negotiating';
        break;
      case NegotiationStatus.accepted:
        color = Colors.green;
        label = 'Agreed ✓';
        break;
      case NegotiationStatus.rejected:
        color = Colors.red;
        label = 'Declined';
        break;
      case NegotiationStatus.expired:
        color = Colors.grey;
        label = 'Expired';
        break;
      case NegotiationStatus.paid:
        color = AppColors.primary;
        label = 'Paid';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  String _counterpartyLabel() {
    final String mode = AppUserSession.instance.activeMode;
    if (mode == 'worker') {
      return 'Client';
    } else if (mode == 'client') {
      return 'Artisan';
    }
    return 'Artisan';
  }

  Widget _buildRoundBubble(NegotiationRound round, bool isMine) {
    final Alignment alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final bool isExtraCharge = _currentNegotiation.type == NegotiationType.extraCharge;
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMine ? AppColors.primary : const Color(0xFFF1F3F6),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMine ? 20 : 6),
                  bottomRight: Radius.circular(isMine ? 6 : 20),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isExtraCharge
                        ? '+GHS ${round.proposedAmount.toStringAsFixed(2)} (Extra Charge)'
                        : 'GHS ${round.proposedAmount.toStringAsFixed(2)} (Quote)',
                    style: AppTypography.titleLarge.copyWith(
                      color: isMine ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (round.note != null && round.note!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      round.note!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isMine ? Colors.white.withValues(alpha: 0.9) : AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
              child: Text(
                '${isMine ? 'You' : _counterpartyLabel()} · ${_formatTime(round.createdAt)}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(bool isOpen, bool isMyTurn, NegotiationRound? lastRound) {
    if (!isOpen) {
      final double finalAmount = _currentNegotiation.agreedAmount ?? _currentNegotiation.initialAmount;
      final bool isExtraCharge = _currentNegotiation.type == NegotiationType.extraCharge;
      final String label = _currentNegotiation.status == NegotiationStatus.accepted
          ? (isExtraCharge ? 'Agreed Extra Charge +GHS ${finalAmount.toStringAsFixed(2)} ✓' : 'Agreed at GHS ${finalAmount.toStringAsFixed(2)} ✓')
          : _currentNegotiation.status == NegotiationStatus.paid
              ? (isExtraCharge ? 'Paid Extra Charge +GHS ${finalAmount.toStringAsFixed(2)} ✓' : 'Paid GHS ${finalAmount.toStringAsFixed(2)} ✓')
              : 'Bargaining Ended (Declined)';
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _currentNegotiation.status == NegotiationStatus.accepted || _currentNegotiation.status == NegotiationStatus.paid
              ? Colors.green.withValues(alpha: 0.08)
              : Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bodyLarge.copyWith(
              color: _currentNegotiation.status == NegotiationStatus.accepted || _currentNegotiation.status == NegotiationStatus.paid
                  ? Colors.green[700]
                  : Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (!isMyTurn) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Text(
                'Waiting for ${_counterpartyLabel().toLowerCase()} to respond...',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Proposer turn actions
    final double amountToAccept = lastRound?.proposedAmount ?? _currentNegotiation.initialAmount;
    final bool isExtraCharge = _currentNegotiation.type == NegotiationType.extraCharge;
    return Column(
      children: <Widget>[
        GradientButton(
          label: isExtraCharge
              ? 'Accept Extra Charge (+GHS ${amountToAccept.toStringAsFixed(2)})'
              : 'Accept GHS ${amountToAccept.toStringAsFixed(2)}',
          onPressed: _accept,
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: SecondaryButton(
                label: 'Counter Offer',
                onPressed: () => setState(() => _isCountering = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryButton(
                label: 'Decline',
                onPressed: _reject,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Propose Counter-Offer',
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: AppInput(
                controller: _amountController,
                hint: '0.00',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: AppInput(
                controller: _noteController,
                hint: 'Add note (optional)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: SecondaryButton(
                label: 'Cancel',
                onPressed: () => setState(() => _isCountering = false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GradientButton(
                label: 'Send Proposal',
                onPressed: _counter,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final int hour = dt.hour;
    final int minute = dt.minute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}
