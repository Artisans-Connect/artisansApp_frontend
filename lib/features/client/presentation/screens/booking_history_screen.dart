import 'package:flutter/material.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../data/job_draft_store.dart';
import '../../data/hidden_bookings_store.dart';
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
  final ScrollController _scrollController = ScrollController();

  String _selectedFilter = 'All';
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  List<ClientBooking> _bookings = <ClientBooking>[];

  int _limit = 10;
  int _offset = 0;
  bool _hasMore = true;

  Map<String, int> _serverCounts = <String, int>{};
  int _localDraftsCount = 0;

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
    _scrollController.addListener(_onScroll);
    _loadCountsAndBookings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BookingHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshSignal != oldWidget.refreshSignal) {
      _loadCountsAndBookings();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreBookings();
    }
  }

  String? _getBackendStatusForFilter(String filter) {
    switch (filter) {
      case 'In Progress':
        return 'matched,scheduled_confirmed,on_the_way,arrived,in_progress,termination_requested';
      case 'Pending Approval':
        return 'pending_client_approval';
      case 'Completed':
        return 'completed';
      case 'Cancelled':
        return 'cancelled,expired';
      case 'Requested':
        return 'searching,matching,draft';
      default:
        return null;
    }
  }

  Future<void> _loadCountsAndBookings() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _offset = 0;
      _hasMore = true;
      _bookings = <ClientBooking>[];
    });
    try {
      await _loadCounts();
      await _loadBookingsPage();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = userMessageFor(e, fallback: 'Failed to load bookings.');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCounts() async {
    try {
      final localDrafts = await JobDraftStore.instance.listBookings();
      final counts = await _jobsService.getMyJobsCounts(forceRefresh: true);
      if (mounted) {
        setState(() {
          _localDraftsCount = localDrafts.length;
          _serverCounts = counts;
        });
      }
    } catch (_) {
      // Silently fail count loading so as not to block overall list view
    }
  }

  Future<void> _loadBookingsPage() async {
    try {
      List<ClientBooking> localDrafts = <ClientBooking>[];
      if (_offset == 0 &&
          (_selectedFilter == 'All' || _selectedFilter == 'Draft')) {
        localDrafts = await JobDraftStore.instance.listBookings();
      }

      final String? statusFilter = _getBackendStatusForFilter(_selectedFilter);
      final List<dynamic> data = await _jobsService.getMyJobs(
        status: statusFilter,
        limit: _limit,
        offset: _offset,
        forceRefresh: true,
      );

      final Set<String> hiddenIds =
          await HiddenBookingsStore.instance.getHiddenIds();

      final List<ClientBooking> newBookings = data
          .map((dynamic item) =>
              ClientBooking.fromApiJob(item as Map<String, dynamic>))
          .where((ClientBooking b) => !hiddenIds.contains(b.id))
          .toList();

      if (!mounted) return;
      setState(() {
        if (_offset == 0) {
          _bookings = <ClientBooking>[...localDrafts, ...newBookings];
        } else {
          _bookings.addAll(newBookings);
        }
        _offset += _limit;
        if (newBookings.length < _limit) {
          _hasMore = false;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = userMessageFor(e, fallback: 'Failed to load bookings.');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreBookings() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final String? statusFilter = _getBackendStatusForFilter(_selectedFilter);
      final List<dynamic> data = await _jobsService.getMyJobs(
        status: statusFilter,
        limit: _limit,
        offset: _offset,
        forceRefresh: true,
      );

      final Set<String> hiddenIds =
          await HiddenBookingsStore.instance.getHiddenIds();

      final List<ClientBooking> newBookings = data
          .map((dynamic item) =>
              ClientBooking.fromApiJob(item as Map<String, dynamic>))
          .where((ClientBooking b) => !hiddenIds.contains(b.id))
          .toList();

      if (!mounted) return;
      setState(() {
        _bookings.addAll(newBookings);
        _offset += _limit;
        if (newBookings.length < _limit) {
          _hasMore = false;
        }
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  int _countForFilter(String filter) {
    if (filter == 'Draft') {
      return _localDraftsCount + (_serverCounts['draft'] ?? 0);
    }
    if (filter == 'In Progress') {
      return (_serverCounts['matched'] ?? 0) +
          (_serverCounts['scheduled_confirmed'] ?? 0) +
          (_serverCounts['on_the_way'] ?? 0) +
          (_serverCounts['arrived'] ?? 0) +
          (_serverCounts['in_progress'] ?? 0) +
          (_serverCounts['termination_requested'] ?? 0);
    }
    if (filter == 'Pending Approval') {
      return _serverCounts['pending_client_approval'] ?? 0;
    }
    if (filter == 'Completed') {
      return _serverCounts['completed'] ?? 0;
    }
    if (filter == 'Cancelled') {
      return (_serverCounts['cancelled'] ?? 0) +
          (_serverCounts['expired'] ?? 0);
    }
    if (filter == 'Requested') {
      return (_serverCounts['searching'] ?? 0) +
          (_serverCounts['matching'] ?? 0);
    }
    if (filter == 'All') {
      final int sum = _serverCounts.values.fold(0, (int a, int b) => a + b);
      return sum + _localDraftsCount;
    }
    return 0;
  }

  bool _isBookingDeletable(ClientBooking booking) {
    if (booking.isLocalDraft) return true;
    final String status = (booking.backendStatus ?? '').toLowerCase();
    return status == 'draft' ||
        status == 'searching' ||
        status == 'matching' ||
        status == 'cancelled' ||
        status == 'completed' ||
        status == 'expired';
  }

  Future<bool> _showDeleteConfirmation(ClientBooking booking) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          title: Text(
            booking.isLocalDraft ? 'Delete Draft?' : 'Hide Booking?',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            booking.isLocalDraft
                ? 'Are you sure you want to permanently delete this draft job?'
                : 'This booking will be hidden from your history tab, but your messages and transaction records will be preserved.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                booking.isLocalDraft ? 'Delete' : 'Hide',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _deleteBooking(ClientBooking booking) async {
    try {
      if (booking.isLocalDraft) {
        await JobDraftStore.instance.delete(booking.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft deleted.')),
        );
      } else {
        await HiddenBookingsStore.instance.hide(booking.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking hidden.')),
        );
      }
      setState(() {
        _bookings.removeWhere((ClientBooking b) => b.id == booking.id);
        if (booking.isLocalDraft) {
          _localDraftsCount =
              _localDraftsCount > 0 ? _localDraftsCount - 1 : 0;
        } else {
          final String rawStatus =
              (booking.backendStatus ?? 'draft').toLowerCase();
          if (_serverCounts.containsKey(rawStatus) &&
              _serverCounts[rawStatus]! > 0) {
            _serverCounts[rawStatus] = _serverCounts[rawStatus]! - 1;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userMessageFor(e, fallback: 'Failed to hide booking.'),
          ),
        ),
      );
    }
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
        onRefresh: _loadCountsAndBookings,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && _bookings.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      ErrorStateView(
                        message: _errorMessage!,
                        onRetry: _loadCountsAndBookings,
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    controller: _scrollController,
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
                                      setState(() {
                                        _selectedFilter = filter;
                                      });
                                      _loadCountsAndBookings();
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (_bookings.isEmpty)
                            Text(
                              'No bookings in this filter yet.',
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            )
                          else
                            ..._bookings.map(
                              (ClientBooking booking) => Dismissible(
                                key: Key(booking.id),
                                direction: _isBookingDeletable(booking)
                                    ? DismissDirection.endToStart
                                    : DismissDirection.none,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24.0),
                                  margin: const EdgeInsets.only(
                                      bottom: AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusLarge),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await _showDeleteConfirmation(booking);
                                },
                                onDismissed: (direction) {
                                  _deleteBooking(booking);
                                },
                                child: ClientBookingCard(
                                  booking: booking,
                                  onTap: () =>
                                      ClientNavigation.handleBookingTap(
                                    context,
                                    booking,
                                  ),
                                ),
                              ),
                            ),
                          if (_isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
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
