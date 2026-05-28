import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mock_worker_job.dart';
import '../state/worker_session_state.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_spacing.dart';
import '../theme/worker_text_styles.dart';
import '../widgets/client_contact_row.dart';
import '../widgets/gradient_button.dart';
import '../widgets/map_placeholder.dart';

class WorkerActivePreStartScreen extends StatelessWidget {
  const WorkerActivePreStartScreen({super.key, required this.job});

  final MockWorkerJob job;

  @override
  Widget build(BuildContext context) {
    final session = WorkerScope.of(context);

    return Scaffold(
      backgroundColor: WorkerColors.background,
      appBar: AppBar(
        backgroundColor: WorkerColors.background,
        elevation: 0,
        title: Column(
          children: [
            Text(
              'ACTIVE BOOKING',
              style: WorkerTextStyles.labelCaps.copyWith(fontSize: 9),
            ),
            Text(
              job.title,
              style: WorkerTextStyles.titleMd.copyWith(fontSize: 14),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _stub(context, 'More actions'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 220,
              child: MapPlaceholder(
                fillHeight: true,
                showPin: true,
                clientPinLabel: 'Client Home',
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: WorkerSpacing.gutter,
                ),
                child: Container(
                  padding: const EdgeInsets.all(WorkerSpacing.md),
                  decoration: BoxDecoration(
                    color: WorkerColors.surface,
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
                            backgroundColor: WorkerColors.primaryFixed,
                            child: Text(
                              job.clientName.substring(0, 1),
                              style: WorkerTextStyles.titleMd.copyWith(
                                color: WorkerColors.primary,
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
                                color: WorkerColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: WorkerColors.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: WorkerSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.clientName, style: WorkerTextStyles.titleMd),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Color(0xFFFFB800),
                                ),
                                Text(
                                  ' ${job.clientRating}',
                                  style: WorkerTextStyles.bodyMd,
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
                WorkerSpacing.gutter,
                0,
                WorkerSpacing.gutter,
                WorkerSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('BOOKING ADDRESS', style: WorkerTextStyles.labelCaps),
                  const SizedBox(height: WorkerSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, color: WorkerColors.outline),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.addressLabel,
                          style: WorkerTextStyles.bodyLg.copyWith(
                            color: WorkerColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: WorkerSpacing.lg),
                  Text('REQUEST DETAILS', style: WorkerTextStyles.labelCaps),
                  const SizedBox(height: WorkerSpacing.sm),
                  Text(
                    job.description,
                    style: WorkerTextStyles.bodyMd,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: WorkerSpacing.xl),
                  OutlinedButton.icon(
                    onPressed: () => _stub(context, 'Directions'),
                    icon: const Icon(Icons.navigation_outlined),
                    label: const Text('Get Directions'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: WorkerSpacing.sm),
                  GradientButton(
                    label: 'Mark as Started',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      session.markJobStarted();
                    },
                  ),
                  const SizedBox(height: WorkerSpacing.md),
                  TextButton(
                    onPressed: () {
                      session.cancelActiveJob();
                    },
                    child: Text(
                      'Cancel Booking',
                      style: WorkerTextStyles.bodyLg.copyWith(
                        color: WorkerColors.error,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action — integration later')),
    );
  }
}
