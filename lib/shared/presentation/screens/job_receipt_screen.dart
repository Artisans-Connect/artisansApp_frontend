import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../data/shared_stub_data.dart';
import '../../widgets/custom_app_bar.dart';

/// Read-only job receipt for workers (mock 66).
class JobReceiptScreen extends StatelessWidget {
  const JobReceiptScreen({super.key});

  static const String routeName = '/shared/job-receipt';

  @override
  Widget build(BuildContext context) {
    final receipt = SharedStubData.sampleJobReceipt;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CustomAppBar(
        title: 'Job receipt',
        showBackButton: true,
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
            Row(
              children: <Widget>[
                Expanded(
                  child: _ReceiptSection(
                    title: 'Time spent',
                    rows: const <_ReceiptRow>[
                      _ReceiptRow(Icons.schedule, '2h 30m'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ReceiptSection(
                    title: 'Earnings',
                    rows: <_ReceiptRow>[
                      _ReceiptRow(
                        Icons.payments_outlined,
                        'GHS ${receipt.amountGhs.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (receipt.notes != null) ...<Widget>[
              const SizedBox(height: 16),
              _ReceiptSection(
                title: 'Notes',
                child: Text(
                  receipt.notes!,
                  style: AppTextStyles.bodyLg,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _ReceiptSection(
              title: 'Completion Photos',
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=256&auto=format&fit=crop',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDim,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image_outlined, color: AppColors.outline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                leading: const Icon(Icons.report_problem_outlined, color: AppColors.error),
                title: Text('Report an issue', style: AppTextStyles.bodyLg.copyWith(color: AppColors.error)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Issue reporting opens here.')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptSection extends StatelessWidget {
  const _ReceiptSection({required this.title, this.rows, this.child});

  final String title;
  final List<_ReceiptRow>? rows;
  final Widget? child;

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
          if (child != null) child!,
          if (rows != null)
            ...rows!.map(
              (_ReceiptRow row) => Padding(
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
