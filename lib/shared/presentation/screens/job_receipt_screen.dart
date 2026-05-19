import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../data/shared_stub_data.dart';

/// Read-only job receipt for workers (mock 66).
class JobReceiptScreen extends StatelessWidget {
  const JobReceiptScreen({super.key});

  static const String routeName = '/shared/job-receipt';

  @override
  Widget build(BuildContext context) {
    final receipt = SharedStubData.sampleJobReceipt;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        ),
        title: Text('Job receipt',
            style: AppTextStyles.displayMd.copyWith(fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          receipt.status,
                          style: AppTextStyles.labelCaps.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text('#${receipt.jobId}',
                          style: AppTextStyles.bodyMd),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(receipt.title,
                      style: AppTextStyles.displayMd.copyWith(fontSize: 26)),
                  const SizedBox(height: 8),
                  Text(_formatDate(receipt.completedAt),
                      style: AppTextStyles.bodyMd),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ReceiptSection(
              title: 'Client',
              rows: <_ReceiptRow>[
                _ReceiptRow(Icons.person_outline, receipt.clientName),
                _ReceiptRow(Icons.location_on_outlined, receipt.location),
              ],
            ),
            const SizedBox(height: 16),
            _ReceiptSection(
              title: 'Payment',
              rows: <_ReceiptRow>[
                _ReceiptRow(
                  Icons.payments_outlined,
                  'GHS ${receipt.amountGhs.toStringAsFixed(2)}',
                ),
              ],
            ),
            if (receipt.notes != null) ...<Widget>[
              const SizedBox(height: 16),
              _ReceiptSection(
                title: 'Notes',
                rows: <_ReceiptRow>[
                  _ReceiptRow(Icons.notes, receipt.notes!),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'This receipt is read-only. Disputes and payouts are handled in a future release.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptSection extends StatelessWidget {
  const _ReceiptSection({required this.title, required this.rows});

  final String title;
  final List<_ReceiptRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title,
              style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...rows.map(
            ( _ReceiptRow row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Icon(row.icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(row.label, style: AppTextStyles.bodyLg),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow {
  const _ReceiptRow(this.icon, this.label);
  final IconData icon;
  final String label;
}

String _formatDate(DateTime date) {
  const List<String> months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final int hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final String period = date.hour >= 12 ? 'PM' : 'AM';
  return '${date.day} ${months[date.month - 1]} ${date.year} · $hour:${date.minute.toString().padLeft(2, '0')} $period';
}
