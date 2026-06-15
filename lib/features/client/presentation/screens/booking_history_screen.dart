import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../models/client_booking.dart';
import '../navigation/client_navigation.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({
    super.key,
    this.embedInShell = false,
    this.refreshSignal = 0,
  });

  final bool embedInShell;
  final int refreshSignal;

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final JobsService _jobsService = JobsService();
  String _selectedFilter = 'All';
  bool _isLoading = true;
  String? _errorMessage;
  List<ClientBooking> _bookings = <ClientBooking>[];

  static const List<String> _filters = <String>[
    'All',
    'In Progress',
    'Pending Approval',
    'Completed',
    'Cancelled',
    'Requested',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void didUpdateWidget(covariant BookingHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshSignal != oldWidget.refreshSignal) {
      _loadBookings();
    }
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final List<dynamic> data = await _jobsService.getMyJobs();
      if (!mounted) return;
      setState(() {
        _bookings = data
            .map((dynamic item) =>
                ClientBooking.fromApiJob(item as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            userMessageFor(e, fallback: 'Failed to load bookings.');
        _isLoading = false;
      });
    }
  }

  List<ClientBooking> get _filteredBookings {
    if (_selectedFilter == 'All') return _bookings;
    return _bookings
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
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && _bookings.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      ErrorStateView(
                        message: _errorMessage!,
                        onRetry: _loadBookings,
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.gutter),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          Text(
                            'Your Past & Ongoing Jobs',
                            style: AppTypography.displaySmall,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _filters.map((String filter) {
                                final bool isSelected =
                                    _selectedFilter == filter;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      right: AppSpacing.md),
                                  child: FilterChip(
                                    label: Text(filter),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      setState(() => _selectedFilter = filter);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (_filteredBookings.isEmpty)
                            Text(
                              'No bookings in this filter yet.',
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            )
                          else
                            ..._filteredBookings.map(
                              (ClientBooking booking) => _BookingCard(
                                booking: booking,
                                onTap: () => ClientNavigation.handleBookingTap(
                                  context,
                                  booking,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.onTap});

  final ClientBooking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String subtitle = booking.status == ClientBookingStatus.requested
        ? 'View interested artisans'
        : '${booking.artisan} · ${booking.status.displayLabel}';
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        title: Text(booking.title),
        subtitle: Text(subtitle),
        trailing: Icon(PhosphorIcons.caretRight),
        onTap: onTap,
      ),
    );
  }
}
