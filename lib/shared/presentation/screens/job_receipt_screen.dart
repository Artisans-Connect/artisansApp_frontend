import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/errors/error_messages.dart';
import 'package:artisans_app/core/services/jobs_service.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/shared/models/job_receipt_view.dart';
import 'package:artisans_app/shared/widgets/custom_app_bar.dart';

/// Read-only job receipt for workers.
class JobReceiptScreen extends StatefulWidget {
  const JobReceiptScreen({super.key});

  static const String routeName = '/shared/job-receipt';

  @override
  State<JobReceiptScreen> createState() => _JobReceiptScreenState();
}

class _JobReceiptScreenState extends State<JobReceiptScreen> {
  final JobsService _jobsService = JobsService();

  @override
  Widget build(BuildContext context) {
    final String? jobId = _jobIdFromArgs(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CustomAppBar(
        title: 'Job receipt',
        showBackButton: true,
      ),
      body: jobId == null
          ? const _ReceiptUnavailable()
          : FutureBuilder<dynamic>(
              future: _jobsService.getJobById(jobId),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    snapshot.data is! Map<String, dynamic>) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        userMessageFor(
                          snapshot.error ?? Exception('Receipt unavailable'),
                          fallback: 'Could not load this receipt.',
                        ),
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge,
                      ),
                    ),
                  );
                }
                return _ReceiptBody(
                  receipt: JobReceiptViewData.fromJson(
                    snapshot.data as Map<String, dynamic>,
                  ),
                );
              },
            ),
    );
  }

  String? _jobIdFromArgs(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) return args;
    if (args is Map<String, dynamic>) {
      return args['job_id'] as String? ??
          args['jobId'] as String? ??
          args['id'] as String?;
    }
    return null;
  }
}

class _ReceiptUnavailable extends StatelessWidget {
  const _ReceiptUnavailable();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Receipt unavailable. Open a completed job to view its receipt.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge,
        ),
      ),
    );
  }
}

class _ReceiptBody extends StatelessWidget {
  const _ReceiptBody({required this.receipt});

  final JobReceiptViewData receipt;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        receipt.status,
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        '#${_shortId(receipt.jobId)}',
                        style: AppTypography.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  receipt.title,
                  style: AppTypography.displayMedium.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(receipt.completedAt),
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ReceiptSection(
            title: 'Client',
            rows: <_ReceiptRow>[
              _ReceiptRow(PhosphorIcons.user, receipt.clientName),
              _ReceiptRow(PhosphorIcons.mapPin, receipt.location),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final List<Widget> sections = <Widget>[
                _ReceiptSection(
                  title: 'Time spent',
                  rows: <_ReceiptRow>[
                    _ReceiptRow(
                      PhosphorIcons.clock,
                      _formatHours(receipt.hoursSpent),
                    ),
                  ],
                ),
                _ReceiptSection(
                  title: 'Earnings',
                  rows: <_ReceiptRow>[
                    _ReceiptRow(
                      PhosphorIcons.money,
                      'GHS ${receipt.amountGhs.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ];

              if (constraints.maxWidth < 360) {
                return Column(
                  children: <Widget>[
                    sections[0],
                    const SizedBox(height: 16),
                    sections[1],
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: sections[0]),
                  const SizedBox(width: 16),
                  Expanded(child: sections[1]),
                ],
              );
            },
          ),
          if (receipt.notes != null) ...<Widget>[
            const SizedBox(height: 16),
            _ReceiptSection(
              title: 'Notes',
              child: Text(receipt.notes!, style: AppTypography.bodyLarge),
            ),
          ],
          if (receipt.photoUrls.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            _ReceiptSection(
              title: 'Completion photos',
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: receipt.photoUrls
                    .map(
                      (String url) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.surfaceContainerHigh,
                            child: Icon(
                              PhosphorIcons.imageBroken,
                              color: AppColors.outline,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
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
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
          ),
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
                      child: Text(row.label, style: AppTypography.bodyLarge),
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

String _shortId(String id) {
  if (id.length <= 8) return id;
  return id.substring(0, 8);
}

String _formatHours(double? hours) {
  if (hours == null) return 'Not recorded';
  if (hours < 1) return '${(hours * 60).round()}m';
  final int wholeHours = hours.floor();
  final int minutes = ((hours - wholeHours) * 60).round();
  if (minutes == 0) return '${wholeHours}h';
  return '${wholeHours}h ${minutes}m';
}

String _formatDate(DateTime date) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final int hour =
      date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final String period = date.hour >= 12 ? 'PM' : 'AM';
  final String minute = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]} ${date.year} - $hour:$minute $period';
}
