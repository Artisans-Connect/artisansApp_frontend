import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key, this.embedInShell = false}) : super(key: key);

  final bool embedInShell;

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> bookingHistory = [
    {
      'id': 1,
      'title': 'Fix leaking kitchen faucet',
      'artisan': 'John Smith',
      'profession': 'Professional Plumber',
      'status': 'Completed',
      'date': 'May 18, 2024',
      'rating': 4.8,
      'amount': '\$150',
      'imageUrl': 'https://via.placeholder.com/100?text=John',
    },
    {
      'id': 2,
      'title': 'Install smart lighting system',
      'artisan': 'Sarah Johnson',
      'profession': 'Expert Electrician',
      'status': 'In Progress',
      'date': 'May 20, 2024',
      'rating': null,
      'amount': '\$280',
      'imageUrl': 'https://via.placeholder.com/100?text=Sarah',
    },
    {
      'id': 3,
      'title': 'Paint bedroom walls',
      'artisan': 'Mike Wilson',
      'profession': 'Professional Painter',
      'status': 'Cancelled',
      'date': 'May 15, 2024',
      'rating': null,
      'amount': '\$200',
      'imageUrl': 'https://via.placeholder.com/100?text=Mike',
    },
    {
      'id': 4,
      'title': 'Deep clean house',
      'artisan': 'Emma Davis',
      'profession': 'Professional Cleaner',
      'status': 'Completed',
      'date': 'May 10, 2024',
      'rating': 4.9,
      'amount': '\$120',
      'imageUrl': 'https://via.placeholder.com/100?text=Emma',
    },
  ];

  List<Map<String, dynamic>> get filteredBookings {
    if (_selectedFilter == 'All') return bookingHistory;
    return bookingHistory
        .where((booking) => booking['status'] == _selectedFilter)
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
              // Header
              Text(
                'Your Past & Ongoing Jobs',
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: AppSpacing.md),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'In Progress', 'Completed', 'Cancelled']
                      .map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
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

              // Bookings List
              if (filteredBookings.isEmpty)
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
                  children: List.generate(filteredBookings.length, (index) {
                    final booking = filteredBookings[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GestureDetector(
                        onTap: () {
                          if (booking['status'] == 'In Progress') {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.liveTracking,
                              arguments: booking,
                            );
                          } else if (booking['status'] == 'Completed' &&
                              booking['rating'] == null) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.rateService,
                              arguments: booking,
                            );
                          }
                        },
                        child: _buildBookingCard(booking),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final statusColor = _getStatusColor(booking['status']);
    final canNavigate = booking['status'] == 'In Progress' ||
        (booking['status'] == 'Completed' && booking['rating'] == null);

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
              // Artisan Avatar
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
                    booking['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        color: AppColors.onPrimary,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Job Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['title'],
                      style: AppTypography.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      booking['artisan'],
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      booking['date'],
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusXLarge),
                ),
                child: Text(
                  booking['status'],
                  style: AppTypography.labelSmall.copyWith(
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking['amount'],
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (booking['rating'] != null)
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFFC107),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${booking['rating']}',
                      style: AppTypography.labelMedium,
                    ),
                  ],
                ),
              if (canNavigate)
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.success;
      case 'In Progress':
        return AppColors.primary;
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
