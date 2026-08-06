import 'package:flutter/material.dart';

import '../../../../core/services/applications_service.dart';
import '../../../../core/services/workers_service.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/category_icon_badge.dart';
import '../../../../shared/widgets/custom_back_button.dart';

class WorkerApplicationDetailScreen extends StatefulWidget {
  const WorkerApplicationDetailScreen({
    super.key,
    required this.application,
  });

  final Map<String, dynamic> application;

  @override
  State<WorkerApplicationDetailScreen> createState() => _WorkerApplicationDetailScreenState();
}

class _WorkerApplicationDetailScreenState extends State<WorkerApplicationDetailScreen> {
  final WorkersService _workersService = WorkersService();
  final ApplicationsService _applicationsService = ApplicationsService();
  bool _isWithdrawing = false;
  bool _isAcceptingCounter = false;

  Future<void> _confirmWithdraw(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Withdraw application?'),
        content: const Text(
          'Are you sure you want to withdraw your application? This request will no longer be available to you.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Withdraw',
              style: TextStyle(color: DesignTokens.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isWithdrawing = true);

    try {
      final Map<String, dynamic> job =
          Map<String, dynamic>.from(widget.application['job'] as Map? ?? const {});
      final String jobId = (job['id'] ?? '').toString();

      await _workersService.withdrawApplication(jobId);

      if (!mounted) return;
      AppToast.showInfo(context, 'Application withdrawn successfully.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not withdraw application.');
      }
    } finally {
      if (mounted) setState(() => _isWithdrawing = false);
    }
  }

  Future<void> _acceptCounterOffer() async {
    final String applicationId = (widget.application['id'] ?? '').toString();
    if (applicationId.isEmpty) return;

    setState(() => _isAcceptingCounter = true);
    try {
      await _applicationsService.acceptCounterOffer(applicationId: applicationId);
      if (!mounted) return;
      AppToast.showSuccess(context, 'Counter-offer accepted! Waiting for client payment.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not accept counter-offer.');
      }
    } finally {
      if (mounted) setState(() => _isAcceptingCounter = false);
    }
  }

  Future<void> _sendCounterOffer() async {
    final Map<String, dynamic> job =
        Map<String, dynamic>.from(widget.application['job'] as Map? ?? const {});
    final String jobId = (job['id'] ?? '').toString();
    final String applicationId = (widget.application['id'] ?? '').toString();
    if (jobId.isEmpty || applicationId.isEmpty) return;

    final double? currentQuote = double.tryParse(
      (widget.application['counter_rate'] ?? widget.application['total_quote'] ?? '').toString(),
    );

    final double? counterRate = await showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) {
        final TextEditingController controller = TextEditingController(
          text: currentQuote != null ? currentQuote.toStringAsFixed(0) : '',
        );
        return AlertDialog(
          title: const Text('Your Counter Offer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (currentQuote != null)
                Text(
                  'Current amount: GHS ${currentQuote.toStringAsFixed(2)}',
                  style: const TextStyle(color: DesignTokens.textSecondary, fontSize: 13),
                ),
              if (currentQuote != null) const SizedBox(height: 12),
              const Text('Enter your proposed amount:', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  prefixText: 'GHS ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  hintText: '0.00',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final double? val = double.tryParse(controller.text.trim());
                if (val != null && val > 0) Navigator.pop(dialogContext, val);
              },
              child: const Text('Send Counter'),
            ),
          ],
        );
      },
    );

    if (counterRate == null || !mounted) return;

    try {
      await _applicationsService.counterApplication(
        jobId: jobId,
        applicationId: applicationId,
        counterRate: counterRate,
      );
      if (!mounted) return;
      AppToast.showSuccess(
        context,
        'Counter-offer of GHS ${counterRate.toStringAsFixed(2)} sent to client.',
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not send counter-offer.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> job =
        Map<String, dynamic>.from(widget.application['job'] as Map? ?? const {});
    final Map<String, dynamic> category =
        Map<String, dynamic>.from(job['categories'] as Map? ?? const {});
    final String applicationStatus =
        (widget.application['status'] ?? 'pending').toString().toLowerCase();
    final String jobStatus = (job['status'] ?? '').toString().toLowerCase();
    final String lastProposedBy = (widget.application['last_proposed_by'] ?? '').toString();
    final double? counterRate = (widget.application['counter_rate'] as num?)?.toDouble();
    final bool clientProposed = lastProposedBy == 'client';
    final bool workerProposed = lastProposedBy == 'worker';
    final bool canAcceptCounter = clientProposed && applicationStatus == 'pending';
    final bool canCounter = applicationStatus == 'pending';

    return Scaffold(
      backgroundColor: DesignTokens.surfaceBase,
      appBar: AppBar(
        backgroundColor: DesignTokens.surfaceBase,
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text('Application details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.gutter),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(DesignTokens.lg),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceCard,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
              border: Border.all(color: DesignTokens.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CategoryIconBadge(
                      iconName: category['icon_name']?.toString(),
                      colorHex: category['color_hex']?.toString(),
                      size: 52,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            (job['title'] ?? 'Job application').toString(),
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: DesignTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (category['name'] ?? 'Service').toString(),
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              color: DesignTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.lg),
                _DetailRow(
                  label: 'Application status',
                  value: _statusLabel(applicationStatus),
                ),
                _DetailRow(
                  label: 'Job status',
                  value: _statusLabel(jobStatus),
                ),
                _DetailRow(
                  label: 'Location',
                  value: (job['address_label'] ?? 'Location pending').toString(),
                ),
                _DetailRow(label: 'Client estimate', value: _budgetLabel(job)),
                if (widget.application['total_quote'] != null)
                  _DetailRow(
                    label: 'Your quote shown to client',
                    value: 'GHS ${widget.application['total_quote']}',
                  ),
                if ((widget.application['message'] ?? '').toString().trim().isNotEmpty)
                  _DetailRow(
                    label: 'Your message',
                    value: widget.application['message'].toString(),
                  ),
                if (widget.application['proposed_rate'] != null)
                  _DetailRow(
                    label: 'Custom amount you entered',
                    value: 'GHS ${widget.application['proposed_rate']}',
                  ),
              ],
            ),
          ),

          // Negotiation status card
          if (counterRate != null || lastProposedBy.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.md),
            Container(
              padding: const EdgeInsets.all(DesignTokens.lg),
              decoration: BoxDecoration(
                color: clientProposed
                    ? const Color(0xFFFFF8E1)
                    : DesignTokens.surfaceCard,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                border: Border.all(
                  color: clientProposed
                      ? const Color(0xFFFFD54F)
                      : DesignTokens.borderSubtle,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 20,
                        color: clientProposed
                            ? const Color(0xFFFF8F00)
                            : DesignTokens.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Negotiation',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: clientProposed
                              ? const Color(0xFFFF8F00)
                              : DesignTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (counterRate != null)
                    _DetailRow(
                      label: clientProposed ? 'Client offers' : 'You proposed',
                      value: 'GHS ${counterRate.toStringAsFixed(2)}',
                    ),
                  Text(
                    clientProposed
                        ? 'The client has proposed a different rate. You can accept this offer or send your own counter.'
                        : workerProposed
                            ? 'You sent a counter-offer. Waiting for the client to respond.'
                            : 'A negotiation is in progress.',
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13,
                      height: 1.5,
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: DesignTokens.md),
          if (counterRate == null && lastProposedBy.isEmpty)
            Text(
              applicationStatus == 'pending'
                  ? 'The client is reviewing applications. We will update this card when a decision is made.'
                  : 'This application reflects the latest job status available.',
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                height: 1.5,
                color: DesignTokens.textSecondary,
              ),
            ),

          // Accept counter-offer button (prominent, when client proposed)
          if (canAcceptCounter) ...[
            const SizedBox(height: DesignTokens.md),
            ElevatedButton(
              onPressed: _isAcceptingCounter ? null : _acceptCounterOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                elevation: 0,
              ),
              child: Text(
                _isAcceptingCounter
                    ? 'Accepting...'
                    : 'Accept Counter (GHS ${counterRate?.toStringAsFixed(2) ?? '\u2014'})',
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],

          // Send counter-offer button (always available when pending)
          if (canCounter) ...[
            const SizedBox(height: DesignTokens.sm),
            OutlinedButton(
              onPressed: _sendCounterOffer,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
              ),
              child: const Text(
                'Send My Counter Offer',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],

          if (applicationStatus == 'pending') ...[
            const SizedBox(height: DesignTokens.lg),
            ElevatedButton(
              onPressed: _isWithdrawing ? null : () => _confirmWithdraw(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                elevation: 0,
              ),
              child: Text(
                _isWithdrawing ? 'Withdrawing...' : 'Withdraw Application',
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _statusLabel(String status) {
    if (status.isEmpty) return 'Unknown';
    return status
        .split('_')
        .map((String word) =>
            word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  static String _budgetLabel(Map<String, dynamic> job) {
    final Object? fixed = job['budget_fixed'];
    final Object? min = job['budget_min'];
    final Object? max = job['budget_max'];
    if (fixed != null) return 'GHS $fixed';
    if (min != null && max != null) return 'GHS $min - $max';
    if (min != null) return 'From GHS $min';
    if (max != null) return 'Up to GHS $max';
    return 'Not specified';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12,
                color: DesignTokens.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DesignTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
