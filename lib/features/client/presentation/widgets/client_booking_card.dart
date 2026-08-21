import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_spacing.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/shared/widgets/artisan_logo_avatar.dart';
import 'package:artisans_app/features/client/presentation/models/client_booking.dart';

/// Minimalist, ultra-clean booking card widget designed for the Client Booking History tab.
class ClientBookingCard extends StatelessWidget {
  const ClientBookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  final ClientBooking booking;
  final VoidCallback onTap;

  bool get _isUnmatched {
    if (booking.isLocalDraft) return false;
    final String art = booking.artisan.trim();
    final bool hasNoWorkerId =
        booking.workerId == null || booking.workerId!.isEmpty;
    final bool hasPlaceholderName =
        art.isEmpty || art == 'Artisan' || art == 'Not posted yet';
    return hasNoWorkerId || hasPlaceholderName;
  }

  String get _displayArtisanName {
    if (booking.isLocalDraft) return 'Draft Job';
    if (_isUnmatched) return 'Unmatched';
    return booking.artisan;
  }

  Color get _displayArtisanNameColor {
    if (booking.isLocalDraft) return AppColors.textPrimary;
    if (_isUnmatched) return AppColors.textMuted;
    return AppColors.textPrimary;
  }

  String get _displayProfession {
    if (booking.isLocalDraft) return 'Saved on this device';
    if (_isUnmatched) {
      if (booking.profession.isNotEmpty &&
          booking.profession.toLowerCase() != 'artisan') {
        return booking.profession;
      }
      return 'No worker assigned';
    }

    if (booking.status == ClientBookingStatus.cancelled) {
      final String prof = booking.profession.trim();
      if (prof.isNotEmpty && prof.toLowerCase() != 'artisan') {
        return '$prof • Terminated midway';
      }
      return 'Terminated midway';
    }

    final String name = _displayArtisanName.toLowerCase();
    final String prof = booking.profession.trim();
    if (prof.isNotEmpty &&
        prof.toLowerCase() != 'artisan' &&
        prof.toLowerCase() != name) {
      return prof;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final _StatusConfig statusConfig = _getStatusConfig(booking);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A2C2418),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header Row: Job Title (Amount reference removed)
                Text(
                  booking.title,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Middle Row: Artisan Avatar + Name/Profession + Status Badge Dot/Pill
                Row(
                  children: <Widget>[
                    // Compact Artisan Avatar
                    ArtisanLogoAvatar(
                      imageUrl: booking.imageUrl,
                      size: 36,
                    ),
                    const SizedBox(width: 10),
                    // Artisan info & verified status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  _displayArtisanName,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: _displayArtisanNameColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (booking.workerIsVerified && !_isUnmatched) ...<Widget>[
                                const SizedBox(width: 4),
                                const Icon(
                                  PhosphorIcons.sealCheck,
                                  size: 15,
                                  color: AppColors.secondary,
                                ),
                              ],
                            ],
                          ),
                          if (_displayProfession.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              _displayProfession,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    // Minimal Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusConfig.backgroundColor,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                        border: Border.all(
                          color: statusConfig.borderColor,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            statusConfig.icon,
                            size: 12,
                            color: statusConfig.foregroundColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusConfig.label,
                            style: AppTypography.labelSmall.copyWith(
                              color: statusConfig.foregroundColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                const Divider(
                  height: 1,
                  thickness: 0.6,
                  color: AppColors.borderSubtle,
                ),
                const SizedBox(height: AppSpacing.xs + 2),

                // Footer Row: Date Metadata + Sleek Terracotta Action Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          PhosphorIcons.calendarBlank,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          booking.date.isNotEmpty ? booking.date : 'Recent',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          statusConfig.actionLabel,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          PhosphorIcons.caretRight,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(ClientBooking booking) {
    if (booking.isLocalDraft) {
      return const _StatusConfig(
        label: 'Draft',
        icon: PhosphorIcons.pencilSimple,
        backgroundColor: Color(0xFFF4EDE6),
        borderColor: Color(0xFFE8D5CB),
        foregroundColor: AppColors.textSecondary,
        actionLabel: 'Resume Draft',
      );
    }

    switch (booking.status) {
      case ClientBookingStatus.inProgress:
        return const _StatusConfig(
          label: 'In Progress',
          icon: PhosphorIcons.clock,
          backgroundColor: Color(0xFFFFF7ED),
          borderColor: Color(0xFFFED7AA),
          foregroundColor: Color(0xFFD97706),
          actionLabel: 'Track Live',
        );

      case ClientBookingStatus.awaitingPayment:
        return const _StatusConfig(
          label: 'Awaiting Payment',
          icon: PhosphorIcons.creditCard,
          backgroundColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFDE68A),
          foregroundColor: Color(0xFFD97706),
          actionLabel: 'Pay Deposit',
        );

      case ClientBookingStatus.accepted:
        return const _StatusConfig(
          label: 'Accepted',
          icon: PhosphorIcons.check,
          backgroundColor: Color(0xFFEFF6FF),
          borderColor: Color(0xFFBFDBFE),
          foregroundColor: Color(0xFF2563EB),
          actionLabel: 'Track Live',
        );

      case ClientBookingStatus.pendingApproval:
        return _StatusConfig(
          label: 'Pending Approval',
          icon: PhosphorIcons.warningCircle,
          backgroundColor: const Color(0xFFFFF1F2),
          borderColor: const Color(0xFFFECDD3),
          foregroundColor: AppColors.primary,
          actionLabel: booking.canRate ? 'Rate Service' : 'View Details',
        );

      case ClientBookingStatus.completed:
        return _StatusConfig(
          label: 'Completed',
          icon: PhosphorIcons.checkCircle,
          backgroundColor: const Color(0xFFF0FDF4),
          borderColor: const Color(0xFFBBF7D0),
          foregroundColor: const Color(0xFF16A34A),
          actionLabel: booking.canRate ? 'Rate Artisan' : 'View Details',
        );

      case ClientBookingStatus.cancelled:
        return const _StatusConfig(
          label: 'Cancelled',
          icon: PhosphorIcons.xCircle,
          backgroundColor: Color(0xFFFEF2F2),
          borderColor: Color(0xFFFECACA),
          foregroundColor: Color(0xFFDC2626),
          actionLabel: 'View Summary',
        );

      case ClientBookingStatus.requested:
        return const _StatusConfig(
          label: 'Requested',
          icon: PhosphorIcons.users,
          backgroundColor: Color(0xFFFAF5FF),
          borderColor: Color(0xEFE9D5FE),
          foregroundColor: Color(0xFF9333EA),
          actionLabel: 'View Applicants',
        );

      case ClientBookingStatus.draft:
        return const _StatusConfig(
          label: 'Draft',
          icon: PhosphorIcons.pencilSimple,
          backgroundColor: Color(0xFFF4EDE6),
          borderColor: Color(0xFFE8D5CB),
          foregroundColor: AppColors.textSecondary,
          actionLabel: 'Resume Draft',
        );
    }
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.actionLabel,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final String actionLabel;
}
