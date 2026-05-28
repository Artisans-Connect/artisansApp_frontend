import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../models/client_booking_stub.dart';
import '../navigation/client_navigation.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key, this.embedInShell = false});

  final bool embedInShell;

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _selectedFilter = 'All';

  static const List<String> _filters = <String>[
    'All',
    'In Progress',
    'Completed',
    'Cancelled',
    'Requested',
  ];

  List<ClientBooking> get _allBookings => ClientBooking.sampleBookings;

  List<ClientBooking> get _filteredBookings {
    if (_selectedFilter == 'All') return _allBookings;
    return _allBookings
        .where((ClientBooking b) => b.status.displayLabel == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Booking History',
        showBackButton: !widget.embedInShell,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Past & Ongoing Jobs',
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((String filter) {
                    final bool isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedFilter = filter);
                        },
                        backgroundColor: AppColors.surfaceContainerLowest,
                        selectedColor: AppColors.primaryContainer,
                        labelStyle: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.onPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_filteredBookings.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: AppColors.outlineVariant,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No bookings found',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: _filteredBookings.map((ClientBooking booking) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GestureDetector(
                        onTap: () =>
                            ClientNavigation.handleBookingTap(context, booking),
                        child: _BookingCard(
                          booking: booking,
                          showNavHint: booking.isNavigable,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.showNavHint,
  });

  final ClientBooking booking;
  final bool showNavHint;

  Color _statusColor(ClientBookingStatus status) {
    switch (status) {
      case ClientBookingStatus.completed:
        return AppColors.success;
      case ClientBookingStatus.inProgress:
      case ClientBookingStatus.accepted:
        return AppColors.primary;
      case ClientBookingStatus.cancelled:
        return AppColors.error;
      case ClientBookingStatus.requested:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(booking.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  child: Image.network(
                    booking.imageUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.title,
                      style: AppTypography.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      booking.artisan,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      booking.date,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                ),
                child: Text(
                  booking.status.displayLabel,
                  style: AppTypography.labelSmall.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.amount,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (booking.rating != null)
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFFC107),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.rating}',
                      style: AppTypography.labelMedium,
                    ),
                  ],
                ),
              if (showNavHint)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
