import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../domain/models/report_model.dart';
import '../../services/reports_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  static const String routeName = '/my-reports';

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  bool _isLoading = true;
  String? _error;
  List<SafetyReport> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reports = await ReportsService.instance.getMyReports();
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = userMessageFor(e);
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'UNDER_REVIEW':
        return Colors.blue;
      case 'NEEDS_EVIDENCE':
        return Colors.purple;
      case 'ACTION_TAKEN':
      case 'RESOLVED':
        return AppColors.success;
      case 'DISMISSED':
        return AppColors.textMuted;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Safety Reports',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(PhosphorIcons.warningCircle,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(_error!, style: AppTypography.bodyMedium),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadReports,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _reports.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIcons.shieldCheck,
                                size: 64, color: AppColors.primary),
                            const SizedBox(height: 16),
                            Text('No Safety Reports',
                                style: AppTypography.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              'You have not submitted any Trust & Safety reports.',
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadReports,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppColors.border),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        report.ticketNumber,
                                        style: AppTypography.titleSmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(report.status)
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          report.status.replaceAll('_', ' '),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: _statusColor(report.status),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(report.category.icon,
                                          size: 16,
                                          color: AppColors.textSecondary),
                                      const SizedBox(width: 6),
                                      Text(
                                        report.category.label,
                                        style: AppTypography.bodySmall
                                            .copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      if (report.isEmergency) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.error,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'EMERGENCY',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    report.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySmall,
                                  ),
                                  if (report.resolutionReason != null &&
                                      report.resolutionReason!.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Resolution Note:',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                          const SizedBox(height: 2),
                                          Text(
                                            report.resolutionReason!,
                                            style: AppTypography.caption
                                                .copyWith(
                                                    color: AppColors
                                                        .textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
