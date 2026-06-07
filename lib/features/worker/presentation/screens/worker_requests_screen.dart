import 'dart:async';
 
import 'package:flutter/material.dart';
 
import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/workers_service.dart';
import '../models/worker_job.dart';
import '../state/worker_session_state.dart';
import '../utils/worker_job_mapper.dart';
import '../widgets/skeleton_box.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../../../shared/widgets/job_requests_map.dart';
import 'job_request_detail_screen.dart';
 
// ─────────────────────────────────────────────────────────────────────────────
// Design tokens (from DESIGN.md)
// ─────────────────────────────────────────────────────────────────────────────
class _T {
  static const Color surfaceBase  = Color(0xFFFFF8F0);
  static const Color surfaceCard  = Color(0xFFFFFFFF);
  static const Color primary      = Color(0xFFC15A3D);
  static const Color primaryDark  = Color(0xFF8B3A2A);
  static const Color textPrimary  = Color(0xFF2C2418);
  static const Color textSecondary= Color(0xFF5C5243);
  static const Color textMuted    = Color(0xFF9B8F83);
  static const Color borderSubtle = Color(0x0F000000);
  static const Color successGreen = Color(0xFF1D9E75);
  static const Color error        = Color(0xFFBA1A1A);
 
  // Derived
  static const Color primaryTint08 = Color(0x14C15A3D);
  static const Color primaryTint16 = Color(0x29C15A3D);
  static const Color warmTint      = Color(0xFFF4EDE6);
  static const Color warmBorder    = Color(0xFFE8D5CB);
  static const Color offlineSurface= Color(0xFFE8DDD4);
 
  static const double radiusMd   = 12;
  static const double radiusLg   = 16;
  static const double radiusXl   = 20;
  static const double radiusFull = 999;
 
  static const double gutter = 20;
  static const double sm     = 8;
  static const double md     = 16;
  static const double lg     = 24;
}
 
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
        widget.online ? _T.successGreen : _T.offlineSurface;
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
                  color: _T.successGreen.withOpacity(0.25),
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
  });
 
  final bool isAvailable;
  final ValueChanged<bool> onChanged;
  final DateTime? lastCheckedAt;
  final bool isSilentRefreshing;
 
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
      padding: const EdgeInsets.all(_T.md),
      decoration: BoxDecoration(
        color: _T.surfaceCard,
        borderRadius: BorderRadius.circular(_T.radiusXl),
        border: Border.all(
          color: isAvailable ? _T.primaryTint16 : _T.borderSubtle,
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
                        color: _T.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        isAvailable ? 'Online & available' : 'Offline',
                        key: ValueKey<bool>(isAvailable),
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isAvailable
                              ? _T.successGreen
                              : _T.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isAvailable,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: _T.successGreen,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: _T.offlineSurface,
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
                    color: isAvailable ? _T.textSecondary : _T.textMuted,
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
                        AlwaysStoppedAnimation<Color>(_T.primary),
                  ),
                )
              else if (lastCheckedAt != null)
                Text(
                  _checkedLabel,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 11,
                    color: _T.textMuted,
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
            color: _T.textSecondary,
          ),
        ),
        if (count != null) ...<Widget>[
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
            decoration: BoxDecoration(
              color: _T.primary,
              borderRadius: BorderRadius.circular(_T.radiusFull),
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
        color: isDistance ? _T.warmTint : _T.surfaceBase,
        borderRadius: BorderRadius.circular(_T.radiusFull),
        border: Border.all(
          color: isDistance ? _T.warmBorder : _T.borderSubtle,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDistance ? _T.primaryDark : _T.textSecondary,
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
 
  /// Initials from a full name string.
  String _initials(String name) {
    final List<String> parts =
        name.trim().split(RegExp(r'\s+')).take(2).toList();
    return parts.map((String p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();
  }
 
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
    final String initials = _initials(job.clientName ?? 'U');
 
    return Container(
      decoration: BoxDecoration(
        color: _T.surfaceCard,
        borderRadius: BorderRadius.circular(_T.radiusXl),
        border: Border.all(color: _T.borderSubtle),
      ),
      child: Column(
        children: <Widget>[
          // ── Top: avatar + name + description + time ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Avatar with initials
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _T.warmTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _T.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        job.clientName ?? 'Client',
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _T.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.description ?? 'No description',
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12,
                          color: _T.textSecondary,
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
                    color: _T.textMuted,
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
 
          // ── Divider ──
          const Divider(height: 1, thickness: 0.5, color: _T.borderSubtle),
 
          // ── Actions row ──
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: onViewDetails,
                    style: TextButton.styleFrom(
                      foregroundColor: _T.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(_T.radiusXl),
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
                  color: _T.borderSubtle,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: onAccept,
                    style: TextButton.styleFrom(
                      foregroundColor: _T.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(_T.radiusXl),
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
              color: _T.warmTint,
              shape: BoxShape.circle,
              border: Border.all(color: _T.warmBorder, width: 1.5),
            ),
            child: Icon(
              isOnline ? Icons.radar_rounded : Icons.power_settings_new,
              color: isOnline ? _T.primary : _T.textMuted,
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
              color: _T.textPrimary,
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
                color: _T.textSecondary,
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
                color: _T.textMuted,
              ),
            ),
          ],
          if (isOnline) ...<Widget>[
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(
                foregroundColor: _T.primary,
                side: const BorderSide(color: _T.primary, width: 1.5),
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
 
    try {
      final List<dynamic> data =
          await _workersService.getJobRequests();
      if (!mounted) return;
      setState(() {
        _jobs = data
            .map((dynamic item) =>
                workerJobFromApi(item as Map<String, dynamic>))
            .toList();
        _viewState = _jobs.isEmpty
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
    final WorkerSessionState session = WorkerScope.of(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JobRequestDetailScreen(
          job: job,
          onAcceptRequest: (accepted) {
            session.acceptJob(accepted);
            _load();
          },
          onAcceptResponse: (accepted) {
            session.acceptJobFromApi(accepted);
            _load();
          },
        ),
      ),
    );
  }
 
  // ── Build ──────────────────────────────────────────────────────────────────
 
  @override
  Widget build(BuildContext context) {
    final WorkerSessionState session = WorkerScope.of(context);
 
    return Scaffold(
      backgroundColor: _T.surfaceBase,
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
                    backgroundColor: _T.surfaceBase,
                    color: _T.primary.withOpacity(0.45),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: RefreshIndicator(
              color: _T.primary,
              backgroundColor: _T.surfaceCard,
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
      backgroundColor: _T.surfaceBase,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: const Text(
        'Job Requests',
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: _T.primary,
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
        padding: const EdgeInsets.all(_T.gutter),
        children: const <Widget>[
          SkeletonBox(height: 112),
          SizedBox(height: _T.md),
          SkeletonBox(height: 170),
          SizedBox(height: _T.md),
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
        _T.gutter,
        _T.md,
        _T.gutter,
        _T.gutter,
      ),
      children: <Widget>[
        // ── Availability card ──────────────────────────────────
        _AvailabilityCard(
          isAvailable: session.isAvailable,
          lastCheckedAt: _lastCheckedAt,
          isSilentRefreshing: _isSilentRefreshing,
          onChanged: (bool value) async {
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
 
        const SizedBox(height: _T.lg),
 
        // ── Empty state ────────────────────────────────────────
        if (_viewState == RequestsViewState.empty)
          _EmptyState(
            isOnline: session.isAvailable,
            onRefresh: _load,
            lastCheckedAt: _lastCheckedAt,
          ),
 
        // ── Section header ─────────────────────────────────────
        if (_viewState == RequestsViewState.loaded) ...<Widget>[
          _SectionHeader(
            label: 'Open requests',
            count: _jobs.length,
          ),
          const SizedBox(height: _T.md),
 
          // ── Job cards ────────────────────────────────────────
          JobRequestsMapPreview(
            jobs: _jobs,
            onOpenJob: _openDetail,
          ),
          const SizedBox(height: _T.md),
          ..._jobs.map(
            (WorkerJob job) => Padding(
              padding: const EdgeInsets.only(bottom: _T.md),
              child: _RequestJobCard(
                job: job,
                onViewDetails: () => _openDetail(job),
                onAccept: () => _openDetail(job),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
