import 'package:flutter/material.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../data/job_draft_store.dart';
import '../models/client_booking.dart';
import '../navigation/client_navigation.dart';
import '../widgets/client_booking_card.dart';

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
    'Draft',
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
      final List<ClientBooking> draftBookings =
          await JobDraftStore.instance.listBookings();
      final List<dynamic> data = await _jobsService.getMyJobs(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _bookings = <ClientBooking>[
          ...draftBookings,
          ...data.map(
            (dynamic item) =>
                ClientBooking.fromApiJob(item as Map<String, dynamic>),
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      final List<ClientBooking> draftBookings =
          await JobDraftStore.instance.listBookings();
      if (!mounted) return;
      setState(() {
        _bookings = draftBookings;
        _errorMessage =
            userMessageFor(e, fallback: 'Failed to load bookings.');
        _isLoading = false;
      });
    }
  }

  int _countForFilter(String filter) {
    if (filter == 'All') return _bookings.length;
    if (filter == 'In Progress') {
      return _bookings
          .where((ClientBooking b) =>
              b.status == ClientBookingStatus.inProgress ||
              b.status == ClientBookingStatus.accepted)
          .length;
    }
    if (filter == 'Draft') {
      return _bookings
          .where((ClientBooking b) =>
              b.status == ClientBookingStatus.draft || b.isLocalDraft)
          .length;
    }
    return _bookings
        .where((ClientBooking b) => b.status.displayLabel == filter)
        .length;
  }

  List<ClientBooking> get _filteredBookings {
    if (_selectedFilter == 'All') return _bookings;
    if (_selectedFilter == 'In Progress') {
      return _bookings
          .where((ClientBooking b) =>
              b.status == ClientBookingStatus.inProgress ||
              b.status == ClientBookingStatus.accepted)
          .toList();
    }
    if (_selectedFilter == 'Draft') {
      return _bookings
          .where((ClientBooking b) =>
              b.status == ClientBookingStatus.draft || b.isLocalDraft)
          .toList();
    }
    return _bookings
        .where((ClientBooking b) => b.status.displayLabel == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Bookings',
        subtitle: 'Your past and ongoing jobs',
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
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _filters.map((String filter) {
                                final bool isSelected =
                                    _selectedFilter == filter;
                                final int count = _countForFilter(filter);
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      right: AppSpacing.md),
                                  child: FilterChip(
                                    label: Text('$filter ($count)'),
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
                              (ClientBooking booking) => ClientBookingCard(
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
