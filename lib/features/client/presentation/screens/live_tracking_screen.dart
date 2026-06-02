import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/worker_tracking_map.dart';
import '../navigation/client_navigation.dart';

class LiveTrackingScreen extends StatefulWidget {
  final Map<String, dynamic>? job;

  const LiveTrackingScreen({
    Key? key,
    this.job,
  }) : super(key: key);

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  String _etaLabel = 'Calculating ETA…';

  final List<Map<String, dynamic>> steps = [
    {
      'title': 'Confirmed',
      'description': 'Job accepted by artisan',
      'icon': PhosphorIcons.checkCircle(),
      'status': 'completed',
    },
    {
      'title': 'On the Way',
      'description': 'Artisan is heading to your location',
      'icon': PhosphorIcons.navigationArrow(),
      'status': 'in_progress',
    },
    {
      'title': 'Arrived',
      'description': 'Artisan has arrived at your location',
      'icon': PhosphorIcons.mapPin(),
      'status': 'pending',
    },
    {
      'title': 'Work in Progress',
      'description': 'Artisan is working on your job',
      'icon': PhosphorIcons.wrench(),
      'status': 'pending',
    },
    {
      'title': 'Completed',
      'description': 'Job is done. Awaiting your approval',
      'icon': PhosphorIcons.checks(),
      'status': 'pending',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job ?? {
      'artisan': 'John Smith',
      'profession': 'Professional Plumber',
      'phone': '+233 24 123 4567',
      'eta': _etaLabel,
      'title': 'Fix leaking kitchen faucet',
      'imageUrl': 'https://via.placeholder.com/200?text=John',
    };

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Live Tracking',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Info Card
              _buildJobInfoCard(job),
              const SizedBox(height: AppSpacing.lg),

              if ((job['worker_id'] as String?) != null &&
                  job['location_lat'] != null &&
                  job['location_lng'] != null)
                WorkerTrackingMap(
                  workerId: job['worker_id'] as String,
                  jobLat: (job['location_lat'] as num).toDouble(),
                  jobLng: (job['location_lng'] as num).toDouble(),
                  onEtaChanged: (eta) => setState(() => _etaLabel = eta),
                )
              else
                Container(
                  height: 300,
                  alignment: Alignment.center,
                  child: Text(
                    'Waiting for artisan location…',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),

              // Progress Timeline
              Text(
                'Job Progress',
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildProgressTimeline(),
              const SizedBox(height: AppSpacing.lg),

              // Artisan Info Card
              _buildArtisanDetailCard(job),
              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ClientNavigation.showCallPlaceholder(
                          context,
                          job['phone'] as String? ?? '+233 24 123 4567',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        side: const BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.phone(), size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Call',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ClientNavigation.openChat(
                          context,
                          conversationId:
                              job['conversationId'] as String? ?? 'conv-live',
                          counterpartUserId: job['counterpartUserId'] as String? ??
                              'worker-live',
                          counterpartName: job['artisan'] as String? ?? 'Artisan',
                          jobId: job['id']?.toString(),
                          jobTitle: job['title'] as String?,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        side: const BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.chatTeardrop(), size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Message',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Completion Progress Indicator
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.checkCircle(),
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Job Nearly Complete',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Once finished, rate the service to complete the job',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Mark as Complete Button
              PrimaryButton(
                label: 'Job Complete - Proceed to Rating →',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.rateService,
                    arguments: widget.job,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // View Booking History Link
              Center(
                child: TextButton(
                  onPressed: () => ClientNavigation.goToBookingsTab(context),
                  child: Text(
                    'View all bookings',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobInfoCard(Map<String, dynamic> job) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job['title'],
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ETA',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onPrimary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    job['eta'] ?? '10 mins away',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusXLarge),
                ),
                child: Text(
                  'In Progress',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline() {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index <= _currentStep;
        final isCurrent = index == _currentStep;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(
                            color: AppColors.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Icon(
                    step['icon'],
                    color: isCompleted ? Colors.white : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Step Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'],
                        style: AppTypography.labelLarge.copyWith(
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        step['description'],
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Connector line
            if (index < steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: AppSpacing.md,
                  bottom: AppSpacing.md,
                ),
                child: Container(
                  height: 40,
                  width: 2,
                  color: isCompleted
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildArtisanDetailCard(Map<String, dynamic> job) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: Image.network(
                job['imageUrl'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    PhosphorIcons.user(),
                    color: AppColors.onPrimary,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['artisan'] ?? 'Artisan Name',
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  job['profession'] ?? 'Professional',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  job['phone'] ?? '+233 24 123 4567',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
