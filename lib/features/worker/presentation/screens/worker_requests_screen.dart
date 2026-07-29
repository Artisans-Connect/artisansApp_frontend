import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/location/device_location_service.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/workers_service.dart';
import '../models/worker_job.dart';
import '../state/worker_session_state.dart';
import '../utils/worker_job_mapper.dart';
import '../widgets/skeleton_box.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../../../shared/widgets/job_requests_map.dart';
import '../../../../shared/widgets/category_icon_badge.dart';
import 'job_request_detail_screen.dart';
import 'worker_application_detail_screen.dart';
import 'worker_booking_history_screen.dart';
import '../utils/worker_application_navigation.dart';
import '../../../../core/theme/design_tokens.dart';
 
 
// ─────────────────────────────────────────────────────────────────────────────
// Local reusable widgets
// ─────────────────────────────────────────────────────────────────────────────
 
/// Pulsing dot indicator — shows as green when online, muted grey when offline.
class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.online});
  final bool online;
 
  @override
  State<_PulseDot> createState() => _PulseDotState();
}
 
class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = Tween<double>(begin: 1, end: 1.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    if (widget.online) _ctrl.repeat(reverse: true);
  }
 
  @override
  void didUpdateWidget(_PulseDot old) {
    super.didUpdateWidget(old);
    if (widget.online && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.online) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final Color dotColor =
        widget.online ? DesignTokens.successGreen : DesignTokens.offlineSurface;
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (widget.online)
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: DesignTokens.successGreen.withAlpha((0.25 * 255).round()),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
 
/// Premium availability toggle card.
class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.isAvailable,
    required this.onChanged,
    required this.lastCheckedAt,
    required this.isSilentRefreshing,
    required this.isAvailabilityLoading,
  });
 
  final bool isAvailable;
  final ValueChanged<bool>? onChanged;
  final DateTime? lastCheckedAt;
  final bool isSilentRefreshing;
  final bool isAvailabilityLoading;
 
  String get _checkedLabel {
    if (lastCheckedAt == null) return '';
    final Duration age = DateTime.now().difference(lastCheckedAt!);
    if (age.inSeconds < 5) return 'just now';
    if (age.inSeconds < 60) return '${age.inSeconds}s ago';
    return '${age.inMinutes}m ago';
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(DesignTokens.md),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(
          color: isAvailable ? DesignTokens.primaryTint16 : DesignTokens.borderSubtle,
          width: isAvailable ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top row — label + toggle
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'AVAILABILITY',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        isAvailabilityLoading
                            ? 'Checking availability...'
                            : isAvailable
                                ? 'Online & available'
                                : 'Offline',
                        key: ValueKey<String>(
                          '$isAvailabilityLoading-$isAvailable',
                        ),
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isAvailable
                              ? DesignTokens.successGreen
                              : DesignTokens.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isAvailable,
                onChanged: isAvailabilityLoading ? null : onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: DesignTokens.successGreen,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: DesignTokens.offlineSurface,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Bottom row — pulse dot + meta + last checked
          Row(
            children: <Widget>[
              _PulseDot(online: isAvailable),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  isAvailable
                      ? 'Receiving nearby requests'
                      : 'Not receiving requests',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isAvailable ? DesignTokens.textSecondary : DesignTokens.textMuted,
                  ),
                ),
              ),
              if (isSilentRefreshing)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(DesignTokens.primary),
                  ),
                )
              else if (lastCheckedAt != null)
                Text(
                  _checkedLabel,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 11,
                    color: DesignTokens.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
 
/// Section header row with optional count badge.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.count});
  final String label;
  final int? count;
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.08,
            color: DesignTokens.textSecondary,
          ),
        ),
        if (count != null) ...<Widget>[
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
            decoration: BoxDecoration(
              color: DesignTokens.primary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
 
/// Tag chip — small pill label on the job card.
class _JobTag extends StatelessWidget {
  const _JobTag({required this.label, this.isDistance = false});
  final String label;
  final bool isDistance;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDistance ? DesignTokens.warmTint : DesignTokens.surfaceBase,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(
          color: isDistance ? DesignTokens.warmBorder : DesignTokens.borderSubtle,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDistance ? DesignTokens.primaryDark : DesignTokens.textSecondary,
        ),
      ),
    );
  }
}
 
/// Premium job request card.
class _RequestJobCard extends StatelessWidget {
  const _RequestJobCard({
    required this.job,
    required this.onViewDetails,
    required this.onAccept,
  });
 
  final WorkerJob job;
  final VoidCallback onViewDetails;
  final VoidCallback onAccept;
 
  /// Relative time from a DateTime.
  String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    final Duration age = DateTime.now().difference(dt);
    if (age.inSeconds < 60) return '${age.inSeconds}s ago';
    if (age.inMinutes < 60) return '${age.inMinutes}m ago';
    return '${age.inHours}h ago';
  }
 
  @override
  Widget build(BuildContext context) {
    final double? totalQuote = job.applicationTotalQuote;
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Column(
        children: <Widget>[
          // ── Top: avatar + name + description + time ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CategoryIconBadge(
                  iconName: job.categoryIconName,
                  colorHex: job.categoryColorHex,
                  size: 46,
                ),
                const SizedBox(width: 12),
                // Name + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        job.clientName,
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.description,
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12,
                          color: DesignTokens.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Relative timestamp
                Text(
                  _relativeTime(job.createdAt),
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 11,
                    color: DesignTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
 
          // ── Tags row ──
          if (_tagsFor(job).isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _tagsFor(job),
              ),
            ),
          if (totalQuote != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.payments_rounded,
                    size: 16,
                    color: DesignTokens.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Quote: ${_formatGhs(totalQuote)}',
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
 
          // ── Divider ──
          const Divider(height: 1, thickness: 0.5, color: DesignTokens.borderSubtle),
 
          // ── Actions row ──
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: onViewDetails,
                    style: TextButton.styleFrom(
                      foregroundColor: DesignTokens.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(DesignTokens.radiusXl),
                        ),
                      ),
                    ),
                    child: const Text(
                      'View details',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 0.5,
                  thickness: 0.5,
                  color: DesignTokens.borderSubtle,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: onAccept,
                    style: TextButton.styleFrom(
                      foregroundColor: DesignTokens.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(DesignTokens.radiusXl),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Accept →',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  List<Widget> _tagsFor(WorkerJob job) {
    final List<Widget> tags = <Widget>[];
    if (job.trade != null) tags.add(_JobTag(label: job.trade!));
    if (job.distanceKm != null) {
      tags.add(_JobTag(
        label: '${job.distanceKm!.toStringAsFixed(1)} km',
        isDistance: true,
      ));
    }
    if (job.area != null) tags.add(_JobTag(label: job.area!));
    return tags;
  }

  String _formatGhs(double amount) => 'GHS ${amount.toStringAsFixed(2)}';
}
 
/// Empty state — used for both online-but-no-jobs and offline states.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isOnline,
    required this.onRefresh,
    this.lastCheckedAt,
  });
 
  final bool isOnline;
  final VoidCallback onRefresh;
  final DateTime? lastCheckedAt;
 
  String get _checkedLabel {
    if (lastCheckedAt == null) return '';
    final Duration age = DateTime.now().difference(lastCheckedAt!);
    if (age.inSeconds < 5) return 'just now';
    if (age.inSeconds < 60) return '${age.inSeconds}s ago';
    return '${age.inMinutes}m ago';
  }
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: <Widget>[
          // Icon ring
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: DesignTokens.warmTint,
              shape: BoxShape.circle,
              border: Border.all(color: DesignTokens.warmBorder, width: 1.5),
            ),
            child: Icon(
              isOnline ? Icons.radar_rounded : Icons.power_settings_new,
              color: isOnline ? DesignTokens.primary : DesignTokens.textMuted,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isOnline ? 'No open requests yet' : 'You\'re offline',
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              isOnline
                  ? 'We keep checking every few seconds — you\'ll be notified the moment one arrives.'
                  : 'Toggle availability above to start receiving nearby job requests.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                color: DesignTokens.textSecondary,
                height: 1.55,
              ),
            ),
          ),
          if (isOnline && lastCheckedAt != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Last checked $_checkedLabel',
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12,
                color: DesignTokens.textMuted,
              ),
            ),
          ],
          if (isOnline) ...<Widget>[
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignTokens.primary,
                side: const BorderSide(color: DesignTokens.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 10),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Refresh now',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PendingApplicationCard extends StatelessWidget {
  const _PendingApplicationCard({
    required this.application,
    required this.onTap,
  });

  final Map<String, dynamic> application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> job =
        Map<String, dynamic>.from(application['job'] as Map? ?? const {});
    final dynamic category = job['categories'];
    final String categoryName = category is Map
        ? (category['name'] ?? 'Service').toString()
        : 'Service';
    final String status = (application['status'] ?? 'pending').toString();
    final bool accepted = status == 'accepted';
    final Object? budget = job['budget_fixed'] ?? job['budget_min'] ?? job['budget_max'];
    final double? totalQuote = (application['total_quote'] as num?)?.toDouble() ??
        (application['proposed_rate'] as num?)?.toDouble();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.md),
        decoration: BoxDecoration(
          color: DesignTokens.surfaceCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          border: Border.all(color: DesignTokens.borderSubtle),
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CategoryIconBadge(
            iconName: category is Map ? category['icon_name']?.toString() : null,
            colorHex: category is Map ? category['color_hex']?.toString() : null,
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  (job['title'] ?? 'Job application').toString(),
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$categoryName · ${job['address_label'] ?? 'Location pending'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12,
                    color: DesignTokens.textSecondary,
                  ),
                ),
                if (budget != null) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    'Budget: GHS $budget',
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.primary,
                    ),
                  ),
                ],
                if (totalQuote != null) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    'Your quote: GHS ${totalQuote.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          _JobTag(label: accepted ? 'Accepted' : 'Pending'),
        ],
        ),
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// View state
// ─────────────────────────────────────────────────────────────────────────────
enum RequestsViewState { loading, loaded, empty, error }
 
// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────
class WorkerRequestsScreen extends StatefulWidget {
  const WorkerRequestsScreen({super.key});
 
  @override
  State<WorkerRequestsScreen> createState() =>
      _WorkerRequestsScreenState();
}
 
class _WorkerRequestsScreenState extends State<WorkerRequestsScreen>
    with WidgetsBindingObserver {
  final WorkersService _workersService = WorkersService();
 
  RequestsViewState _viewState = RequestsViewState.loading;
  List<WorkerJob> _jobs = <WorkerJob>[];
  List<Map<String, dynamic>> _applications = <Map<String, dynamic>>[];
  String? _errorMessage;
  Timer? _refreshTimer;
  bool _isLoadingRequests = false;
  bool _isSilentRefreshing = false;
  DateTime? _lastCheckedAt;
 
  // ── Lifecycle ──────────────────────────────────────────────────────────────
 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _load(silent: true),
    );
  }
 
  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
 
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load(silent: true);
  }
 
  // ── Data loading ───────────────────────────────────────────────────────────
 
  Future<void> _load({bool silent = false}) async {
    if (_isLoadingRequests) return;
    _isLoadingRequests = true;
 
    if (!silent) {
      setState(() {
        _viewState = RequestsViewState.loading;
        _errorMessage = null;
        _isSilentRefreshing = false;
      });
    } else if (mounted) {
      setState(() => _isSilentRefreshing = true);
    }
 
    if (mounted) {
      try {
        final session = WorkerScope.read(context);
        unawaited(session.loadAvailability());
      } catch (_) {}
    }

    try {
      final List<dynamic> results = await Future.wait<dynamic>([
        _workersService.getJobRequests(),
        _workersService.getApplications(),
      ]);
      final List<dynamic> data = results[0] as List<dynamic>;
      final List<dynamic> applications = results[1] as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _jobs = data
            .map((dynamic item) =>
                workerJobFromApi(item as Map<String, dynamic>))
            .toList();
        _applications = applications
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
            .toList();
        _viewState = _jobs.isEmpty && _applications.isEmpty
            ? RequestsViewState.empty
            : RequestsViewState.loaded;
        _lastCheckedAt = DateTime.now();
        _isSilentRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (silent) {
        setState(() => _isSilentRefreshing = false);
      } else {
        setState(() {
          _errorMessage =
              userMessageFor(e, fallback: 'Failed to load requests.');
          _viewState = RequestsViewState.error;
        });
      }
    } finally {
      _isLoadingRequests = false;
    }
  }
 
  // ── Navigation ─────────────────────────────────────────────────────────────
 
  void _openDetail(WorkerJob job) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JobRequestDetailScreen(
          job: job,
          onAcceptRequest: (accepted) {
            _load();
          },
          onAcceptResponse: (accepted) {
            _load();
          },
        ),
      ),
    );
  }

  Future<void> _openApplication(Map<String, dynamic> application) async {
    final Map<String, dynamic> job =
        Map<String, dynamic>.from(application['job'] as Map? ?? const {});
    final WorkerApplicationDestination destination =
        workerApplicationDestination(
      (application['status'] ?? '').toString(),
      (job['status'] ?? '').toString(),
    );

    if (destination == WorkerApplicationDestination.activeBooking) {
      final WorkerSessionState session = WorkerScope.of(context);
      await session.loadActiveJob();
      if (session.hasActiveJob || !mounted) return;
    } else if (destination == WorkerApplicationDestination.history) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const WorkerBookingHistoryScreen(),
        ),
      );
      return;
    }

    if (!mounted) return;
    final dynamic updated = await Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (_) => WorkerApplicationDetailScreen(
          application: application,
        ),
      ),
    );
    if (updated == true && mounted) {
      _load();
    }
  }
 
  // ── Build ──────────────────────────────────────────────────────────────────
 
  @override
  Widget build(BuildContext context) {
    final WorkerSessionState session = WorkerScope.of(context);
 
    return Scaffold(
      backgroundColor: DesignTokens.surfaceBase,
      appBar: _buildAppBar(),
      body: Column(
        children: <Widget>[
          // Slim silent-refresh progress bar at the very top
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            child: _isSilentRefreshing
                ? LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: DesignTokens.surfaceBase,
                    color: DesignTokens.primary.withAlpha((0.45 * 255).round()),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: RefreshIndicator(
              color: DesignTokens.primary,
              backgroundColor: DesignTokens.surfaceCard,
              onRefresh: _load,
              child: _buildBody(session),
            ),
          ),
        ],
      ),
    );
  }
 
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: DesignTokens.surfaceBase,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: const Text(
        'Job Requests',
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: DesignTokens.primary,
          letterSpacing: 0.01,
        ),
      ),
    );
  }
 
  // ── Body ───────────────────────────────────────────────────────────────────
 
  Widget _buildBody(WorkerSessionState session) {
    // Loading skeleton
    if (_viewState == RequestsViewState.loading) {
      return ListView(
        padding: const EdgeInsets.all(DesignTokens.gutter),
        children: const <Widget>[
          SkeletonBox(height: 112),
          SizedBox(height: DesignTokens.md),
          SkeletonBox(height: 170),
          SizedBox(height: DesignTokens.md),
          SkeletonBox(height: 170),
        ],
      );
    }
 
    // Error state
    if (_viewState == RequestsViewState.error) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          ErrorStateView(
            message: _errorMessage!,
            title: 'Could not load requests',
            onRetry: _load,
          ),
        ],
      );
    }
 
    // Loaded + empty
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.gutter,
        DesignTokens.md,
        DesignTokens.gutter,
        DesignTokens.gutter,
      ),
      children: <Widget>[
        // ── Availability card ──────────────────────────────────
        _AvailabilityCard(
          isAvailable: session.isAvailable,
          isAvailabilityLoading: session.isAvailabilityLoading,
          lastCheckedAt: _lastCheckedAt,
          isSilentRefreshing: _isSilentRefreshing,
          onChanged: (bool value) async {
            if (value) {
              final bool hasLoc =
                  await DeviceLocationService.requestPermissionInteractive(context);
              if (!hasLoc) return;
            }
            final bool ok = await session.setAvailable(value);
            if (ok && mounted) {
              await _load();
            }
            if (!ok && mounted) {
              AppToast.showError(
                context,
                Exception('Could not update availability.'),
                fallback: 'Could not update availability.',
              );
            }
          },
        ),
 
        const SizedBox(height: DesignTokens.lg),
 
        // ── Empty state ────────────────────────────────────────
        if (_viewState == RequestsViewState.empty)
          _EmptyState(
            isOnline: session.isAvailable,
            onRefresh: _load,
            lastCheckedAt: _lastCheckedAt,
          ),
 
        // ── Section header ─────────────────────────────────────
        if (_viewState == RequestsViewState.loaded) ...<Widget>[
          if (_applications.isNotEmpty) ...<Widget>[
            _SectionHeader(
              label: 'Pending applications',
              count: _applications.length,
            ),
            const SizedBox(height: DesignTokens.md),
            ..._applications.map(
              (Map<String, dynamic> application) => Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.md),
                child: _PendingApplicationCard(
                  application: application,
                  onTap: () => _openApplication(application),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.sm),
          ],
          if (_jobs.isNotEmpty) ...<Widget>[
          _SectionHeader(
            label: 'Open requests',
            count: _jobs.length,
          ),
          const SizedBox(height: DesignTokens.md),
 
          // ── Job cards ────────────────────────────────────────
          JobRequestsMapPreview(
            jobs: _jobs,
            onOpenJob: _openDetail,
          ),
          const SizedBox(height: DesignTokens.md),
          ..._jobs.map(
            (WorkerJob job) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.md),
              child: _RequestJobCard(
                job: job,
                onViewDetails: () => _openDetail(job),
                onAccept: () => _openDetail(job),
              ),
            ),
          ),
          ],
        ],
      ],
    );
  }
}
