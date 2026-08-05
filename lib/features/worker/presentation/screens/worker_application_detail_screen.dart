import 'package:flutter/material.dart';

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
  bool _isWithdrawing = false;

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

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> job =
        Map<String, dynamic>.from(widget.application['job'] as Map? ?? const {});
    final Map<String, dynamic> category =
        Map<String, dynamic>.from(job['categories'] as Map? ?? const {});
    final String applicationStatus =
        (widget.application['status'] ?? 'pending').toString().toLowerCase();
    final String jobStatus = (job['status'] ?? '').toString().toLowerCase();

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
          const SizedBox(height: DesignTokens.md),
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
