import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/workers_service.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../models/mock_worker_job.dart';
import '../state/worker_session_state.dart';
import '../widgets/client_contact_row.dart';
import '../widgets/gradient_button.dart';
import '../../../../shared/widgets/job_site_map.dart';
class WorkerActivePreStartScreen extends StatefulWidget {
  const WorkerActivePreStartScreen({super.key, required this.job});
  final MockWorkerJob job;
  @override
  State<WorkerActivePreStartScreen> createState() => _WorkerActivePreStartScreenState();
}
class _WorkerActivePreStartScreenState extends State<WorkerActivePreStartScreen> {
  final WorkersService _workersService = WorkersService();
  bool _isStarting = false;
  @override
  Widget build(BuildContext context) {
    final session = WorkerScope.of(context);
    final job = widget.job;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          children: [
            Text(
              'ACTIVE BOOKING',
              style: AppTypography.labelCaps.copyWith(fontSize: 9),
            ),
            Text(
              job.title,
              style: AppTypography.titleMd.copyWith(fontSize: 14),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.dotsThreeVertical()),
            onPressed: () => _stub(context, 'More actions'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            JobSiteMap(
              latitude: job.latitude,
              longitude: job.longitude,
              label: job.addressLabel,
            ),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryFixed,
                            child: Text(
                              job.clientName.substring(0, 1),
                              style: AppTypography.titleMd.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.clientName, style: AppTypography.titleMd),
                            Row(
                              children: [
                                Icon(
                                  PhosphorIcons.star(),
                                  size: 14,
                                  color: Color(0xFFFFB800),
                                ),
                                Text(
                                  ' ${job.clientRating}',
                                  style: AppTypography.bodyMd,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ClientContactRow(
                        onMessage: () => _stub(context, 'Message'),
                        onCall: () => _stub(context, 'Call'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                0,
                AppSpacing.gutter,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('BOOKING ADDRESS', style: AppTypography.labelCaps),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(PhosphorIcons.mapPin(), color: AppColors.outline),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.addressLabel,
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('REQUEST DETAILS', style: AppTypography.labelCaps),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    job.description,
                    style: AppTypography.bodyMd,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  OutlinedButton.icon(
                    onPressed: () => _stub(context, 'Directions'),
                    icon: Icon(PhosphorIcons.navigationArrow()),
                    label: const Text('Get Directions'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GradientButton(
                    label: 'Mark as Started',
                    isLoading: _isStarting,
                    enabled: !_isStarting,
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      setState(() => _isStarting = true);
                      try {
                        await _workersService.startJob(job.id);
                        if (mounted) {
                          session.markJobStarted();
                        }
                      } catch (e) {
                        if (mounted) {
                          AppToast.showError(context, e, fallback: 'Failed to start job.');
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isStarting = false);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () {
                      session.cancelActiveJob();
                    },
                    child: Text(
                      'Cancel Booking',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _stub(BuildContext context, String action) {
    AppToast.showInfo(context, '$action — coming soon');
  }
}