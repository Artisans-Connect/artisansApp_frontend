import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/artisan_logo_avatar.dart';
import '../../../../core/navigation/app_routes.dart';
import '../models/client_booking.dart';
import '../navigation/client_navigation.dart';

class BookingSummarySheet extends StatelessWidget {
  final ClientBooking booking;

  const BookingSummarySheet({
    super.key,
    required this.booking,
  });

  static void show(BuildContext context, ClientBooking booking) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => BookingSummarySheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = booking.status == ClientBookingStatus.completed;
    final bool isCancelled = booking.status == ClientBookingStatus.cancelled;
    final bool isDraft = booking.isLocalDraft || booking.status == ClientBookingStatus.draft;
    final bool isRequested = booking.status == ClientBookingStatus.requested;
    final bool hasWorkerProfile = booking.counterpartUserId != null && booking.counterpartUserId!.isNotEmpty;

    final String modeLabel = (booking.jobMode ?? '').toLowerCase() == 'scheduled'
        ? 'Scheduled Appointment'
        : (booking.jobMode ?? '').toLowerCase() == 'instant'
            ? 'Instant Dispatch'
            : '';

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (BuildContext _, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Top Drag Handle & Dismiss Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(PhosphorIcons.x, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Job Title & Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            booking.title,
                            style: AppTypography.displaySmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (modeLabel.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 4),
                            Row(
                              children: <Widget>[
                                Icon(
                                  (booking.jobMode ?? '').toLowerCase() == 'scheduled'
                                      ? PhosphorIcons.calendarCheck
                                      : PhosphorIcons.lightning,
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  modeLabel,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFFF0FDF4)
                            : isCancelled
                                ? const Color(0xFFFEF2F2)
                                : isDraft
                                    ? const Color(0xFFF4EDE6)
                                    : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFFBBF7D0)
                              : isCancelled
                                  ? const Color(0xFFFECACA)
                                  : isDraft
                                      ? const Color(0xFFE8D5CB)
                                      : const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: Text(
                        booking.status.displayLabel,
                        style: AppTypography.labelMedium.copyWith(
                          color: isCompleted
                              ? const Color(0xFF16A34A)
                              : isCancelled
                                  ? const Color(0xFFDC2626)
                                  : isDraft
                                      ? AppColors.textSecondary
                                      : const Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Section 1: Artisan / Worker Info Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: <Widget>[
                      ArtisanLogoAvatar(
                        imageUrl: booking.imageUrl,
                        size: 44,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    booking.artisan.isNotEmpty &&
                                            booking.artisan != 'Artisan' &&
                                            booking.artisan != 'Not posted yet'
                                        ? booking.artisan
                                        : 'Unmatched',
                                    style: AppTypography.labelLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (booking.workerIsVerified) ...<Widget>[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    PhosphorIcons.sealCheck,
                                    size: 16,
                                    color: AppColors.secondary,
                                  ),
                                ],
                              ],
                            ),
                            if (booking.profession.isNotEmpty &&
                                booking.profession.toLowerCase() != 'artisan') ...<Widget>[
                              const SizedBox(height: 2),
                              Text(
                                booking.profession,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (booking.rating != null) ...<Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                PhosphorIcons.starFill,
                                size: 14,
                                color: Color(0xDFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                booking.rating!.toStringAsFixed(1),
                                style: AppTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (booking.phone != null && booking.phone!.isNotEmpty) ...<Widget>[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(PhosphorIcons.phoneCall, size: 18, color: AppColors.primary),
                          onPressed: () => ClientNavigation.callPhone(context, booking.phone!),
                          tooltip: 'Call Artisan',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 2: Job Execution Timeline & Schedule Details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(PhosphorIcons.calendarBlank, size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 8),
                          Text(
                            'Created:',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            booking.date.isNotEmpty ? booking.date : 'Recent',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (booking.scheduledFor != null && booking.scheduledFor!.isNotEmpty) ...<Widget>[
                        const Divider(height: 16, thickness: 0.5),
                        Row(
                          children: <Widget>[
                            const Icon(PhosphorIcons.clock, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Text(
                              'Scheduled For:',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              booking.scheduledFor!.replaceAll('T', ' ').split('.').first,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (booking.workEndedAt != null && booking.workEndedAt!.isNotEmpty) ...<Widget>[
                        const Divider(height: 16, thickness: 0.5),
                        Row(
                          children: <Widget>[
                            const Icon(PhosphorIcons.checkCircle, size: 16, color: Color(0xFF16A34A)),
                            const SizedBox(width: 8),
                            Text(
                              'Work Completed:',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              booking.workEndedAt!.replaceAll('T', ' ').split('.').first,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 3: Financial & Settlement Breakdown
                if (booking.amount.isNotEmpty || booking.grossAmount != null) ...<Widget>[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Settlement & Budget',
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              booking.amount.isNotEmpty
                                  ? booking.amount
                                  : 'GHS ${booking.grossAmount?.toStringAsFixed(2) ?? '—'}',
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        if (booking.baseRate != null ||
                            booking.distanceCost != null ||
                            booking.platformFee != null) ...<Widget>[
                          const Divider(height: 16, thickness: 0.5),
                          if (booking.baseRate != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Base Service Fee', style: AppTypography.bodySmall),
                                  Text(
                                    'GHS ${booking.baseRate!.toStringAsFixed(2)}',
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          if (booking.distanceCost != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Logistics / Distance', style: AppTypography.bodySmall),
                                  Text(
                                    'GHS ${booking.distanceCost!.toStringAsFixed(2)}',
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          if (booking.urgencyPremium != null && booking.urgencyPremium! > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Urgency Premium', style: AppTypography.bodySmall),
                                  Text(
                                    'GHS ${booking.urgencyPremium!.toStringAsFixed(2)}',
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          if (booking.platformFee != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Platform Fee', style: AppTypography.bodySmall),
                                  Text(
                                    'GHS ${booking.platformFee!.toStringAsFixed(2)}',
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Section 4: Cancellation Audit Log
                if (isCancelled) ...<Widget>[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(PhosphorIcons.warningCircle, size: 16, color: AppColors.error),
                            const SizedBox(width: 6),
                            Text(
                              'Cancellation Details',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (booking.cancelledBy != null && booking.cancelledBy!.isNotEmpty)
                          Text(
                            'Initiated By: ${booking.cancelledBy}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        if (booking.cancellationStage != null && booking.cancellationStage!.isNotEmpty)
                          Text(
                            'Stage: ${booking.cancellationStage!.replaceAll('_', ' ')}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        if (booking.cancellationFee != null && booking.cancellationFee! > 0)
                          Text(
                            'Cancellation Fee: ${booking.cancellationFeeCurrency ?? 'GHS'} ${booking.cancellationFee!.toStringAsFixed(2)}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (booking.cancelledReason != null && booking.cancelledReason!.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 6),
                          Text(
                            'Reason: "${booking.cancelledReason}"',
                            style: AppTypography.bodySmall.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Section 5: Primary Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (isCompleted && hasWorkerProfile) {
                        ClientNavigation.openArtisanProfile(
                          context,
                          userId: booking.counterpartUserId!,
                          name: booking.artisan,
                        );
                      } else if (isCancelled) {
                        ClientNavigation.pushFlow(context, AppRoutes.jobPostCategory);
                      } else if (isDraft) {
                        ClientNavigation.openJobDraft(context, booking);
                      } else if (isRequested) {
                        ClientNavigation.pushFlow(context, AppRoutes.jobApplicants, arguments: booking.toMap());
                      }
                    },
                    child: Text(
                      isCompleted && hasWorkerProfile
                          ? 'Book Artisan Again'
                          : isCancelled
                              ? 'Post Similar Job'
                              : isDraft
                                  ? 'Resume Job Draft'
                                  : isRequested
                                      ? 'View Applicants'
                                      : 'Done',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
