import 'dart:async';
import 'dart:math' as math;
 
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
 
import '../../../../core/errors/error_messages.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/job_realtime_service.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/worker_tracking_map.dart';
import '../models/client_booking.dart';
import '../navigation/client_navigation.dart';
 
// ---------------------------------------------------------------------------
// Design tokens (mirrors DESIGN.md)
// ---------------------------------------------------------------------------
class _T {
  static const Color surfaceBase = Color(0xFFFFF8F0);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFC15A3D);
  static const Color primaryDark = Color(0xFF8B3A2A);
  static const Color accentGold = Color(0xFFE6A017);
  static const Color accentWarm = Color(0xFFD97706);
  static const Color textPrimary = Color(0xFF2C2418);
  static const Color textSecondary = Color(0xFF5C5243);
  static const Color borderSubtle = Color(0x0F000000);
  static const Color successGreen = Color(0xFF00E676);
  static const Color error = Color(0xFFBA1A1A);
 
  // Derived
  static const Color primaryContainer = Color(0xFFF7E8E3);
  static const Color goldContainer = Color(0xFFFDF3DC);
  static const Color shadowDeep = Color(0x1A2C2418);
  static const Color shadowMid = Color(0x0D2C2418);
  static const Color shimmer = Color(0xFFFFF0E6);
}
 
BoxDecoration _premiumCard({
  Color color = _T.surfaceCard,
  double radius = 20,
  bool elevated = true,
}) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: _T.borderSubtle, width: 1),
      boxShadow: elevated
          ? <BoxShadow>[
              const BoxShadow(
                color: _T.shadowDeep,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
              const BoxShadow(
                color: _T.shadowMid,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ]
          : null,
    );
 
// ---------------------------------------------------------------------------
// Mini-hero illustrations (pure Flutter / Canvas — no external assets needed)
// ---------------------------------------------------------------------------
 
/// Wraps a hero SVG-style custom painter with a warm gradient backdrop.
class _MiniHero extends StatelessWidget {
  final Widget child;
  final double height;
  const _MiniHero({required this.child, this.height = 140});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0E6), Color(0xFFFFF8F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _T.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          // decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: _DecorCircle(size: 120, color: _T.primary.withOpacity(0.07)),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: _DecorCircle(size: 90, color: _T.accentGold.withOpacity(0.10)),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: _DecorCircle(size: 20, color: _T.primary.withOpacity(0.12)),
          ),
          Center(child: child),
        ],
      ),
    );
  }
}
 
class _DecorCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _DecorCircle({required this.size, required this.color});
 
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
 
// Status-specific hero content
Widget _heroForStep(int step) {
  switch (step) {
    case 0:
      return _ConfirmedHero();
    case 1:
      return _OnTheWayHero();
    case 2:
      return _ArrivedHero();
    case 3:
      return _InProgressHero();
    case 4:
      return _CompletedHero();
    default:
      return _ConfirmedHero();
  }
}
 
class _ConfirmedHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _T.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: _T.primary.withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: _T.primary, size: 36),
        ),
        const SizedBox(height: 12),
        Text('Booking Confirmed',
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _T.textPrimary)),
        const SizedBox(height: 2),
        Text('Your artisan has accepted the job',
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12,
                color: _T.textSecondary)),
      ],
    );
  }
}
 
class _OnTheWayHero extends StatefulWidget {
  @override
  State<_OnTheWayHero> createState() => _OnTheWayHeroState();
}
 
class _OnTheWayHeroState extends State<_OnTheWayHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.92, end: 1.06).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulse,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _T.goldContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: _T.accentGold.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: const Icon(Icons.directions_bike_rounded,
                color: _T.accentGold, size: 34),
          ),
        ),
        const SizedBox(height: 12),
        Text('On the Way',
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _T.textPrimary)),
        const SizedBox(height: 2),
        Text('Your artisan is heading to you',
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12,
                color: _T.textSecondary)),
      ],
    );
  }
}
 
class _ArrivedHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: _T.successGreen.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: const Icon(Icons.location_on_rounded,
              color: Color(0xFF2E7D32), size: 36),
        ),
        const SizedBox(height: 12),
        Text('Artisan Arrived',
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _T.textPrimary)),
        const SizedBox(height: 2),
        Text('Please welcome them in',
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12,
                color: _T.textSecondary)),
      ],
    );
  }
}
 
class _InProgressHero extends StatefulWidget {
  @override
  State<_InProgressHero> createState() => _InProgressHeroState();
}
 
class _InProgressHeroState extends State<_InProgressHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _spin;
 
  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _spin = Tween<double>(begin: 0, end: 2 * math.pi).animate(_ctrl);
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _spin,
          builder: (_, child) => Transform.rotate(angle: _spin.value, child: child),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _T.primaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: _T.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: const Icon(Icons.settings_rounded,
                color: _T.primary, size: 36),
          ),
        ),
        const SizedBox(height: 12),
        Text('Work in Progress',
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _T.textPrimary)),
        const SizedBox(height: 2),
        Text('Sit back, your artisan is at it',
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12,
                color: _T.textSecondary)),
      ],
    );
  }
}
 
class _CompletedHero extends StatefulWidget {
  @override
  State<_CompletedHero> createState() => _CompletedHeroState();
}
 
class _CompletedHeroState extends State<_CompletedHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _scale,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_T.primary, _T.accentGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: _T.primary.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10)),
              ],
            ),
            child: const Icon(Icons.celebration_rounded,
                color: Colors.white, size: 34),
          ),
        ),
        const SizedBox(height: 12),
        Text('Job Completed! 🎉',
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _T.textPrimary)),
        const SizedBox(height: 2),
        Text('Share your experience with a rating',
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12,
                color: _T.textSecondary)),
      ],
    );
  }
}
 
// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------
 
class LiveTrackingScreen extends StatefulWidget {
  final Map<String, dynamic>? job;
 
  const LiveTrackingScreen({
    super.key,
    this.job,
  });
 
  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}
 
class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with TickerProviderStateMixin {
  final JobsService _jobsService = JobsService();
  final JobRealtimeService _realtime = JobRealtimeService();
 
  Map<String, dynamic>? _job;
  bool _loading = true;
  bool _requestingAnotherWorker = false;
  String? _loadError;
  int _currentStep = 0;
  String _etaLabel = 'Calculating ETA…';
 
  // Animation for timeline step transitions
  late AnimationController _stepPulse;
 
  List<Map<String, dynamic>> get _steps => <Map<String, dynamic>>[
        {
          'title': 'Confirmed',
          'description': 'Job accepted by artisan',
          'icon': Icons.check_circle_rounded,
        },
        {
          'title': 'On the Way',
          'description': 'Artisan is heading to your location',
          'icon': Icons.directions_bike_rounded,
        },
        {
          'title': 'Arrived',
          'description': 'Artisan has arrived at your location',
          'icon': Icons.location_on_rounded,
        },
        {
          'title': 'Work in Progress',
          'description': 'Artisan is working on your job',
          'icon': Icons.settings_rounded,
        },
        {
          'title': 'Completed',
          'description': 'Job is done. Awaiting your approval',
          'icon': Icons.celebration_rounded,
        },
      ];
 
  @override
  void initState() {
    super.initState();
    _stepPulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
 
    _job = widget.job != null ? Map<String, dynamic>.from(widget.job!) : null;
    _applyStepFromStatus(_job?['status'] as String?);
    _loadJobDetails();
    final String? jobId = _currentJobId;
    if (jobId != null && jobId.isNotEmpty) {
      _realtime.subscribeToJob(jobId, onUpdate: _handleJobUpdate);
    }
  }
 
  String? get _currentJobId =>
      _job?['job_id'] as String? ??
      _job?['jobId'] as String? ??
      _job?['id'] as String?;
 
  Future<void> _loadJobDetails() async {
    final String? jobId = _currentJobId;
    if (jobId == null || jobId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final dynamic raw = await _jobsService.getJobById(jobId);
      if (!mounted) return;
      if (raw is Map<String, dynamic>) {
        final ClientBooking booking = ClientBooking.fromApiJob(raw);
        setState(() {
          _job = booking.toTrackingMap();
          _loading = false;
          _loadError = null;
        });
        _applyStepFromStatus(booking.backendStatus);
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = userMessageFor(e, fallback: 'Could not load job details.');
      });
    }
  }
 
  void _handleJobUpdate(Map<String, dynamic> job) {
    unawaited(_refreshFromRealtimeJob(job));
  }
 
  Future<void> _refreshFromRealtimeJob(Map<String, dynamic> job) async {
    Map<String, dynamic> fullJob = job;
    final String? jobId = job['id'] as String?;
    if (jobId != null && jobId.isNotEmpty) {
      try {
        final dynamic fetched = await _jobsService.getJobById(jobId);
        if (fetched is Map<String, dynamic>) {
          fullJob = fetched;
        }
      } catch (_) {
        fullJob = <String, dynamic>{...?_job, ...job};
      }
    }
    final ClientBooking booking = ClientBooking.fromApiJob(fullJob);
    if (!mounted) return;
    setState(() {
      _job = booking.toTrackingMap();
      _loading = false;
      _loadError = null;
    });
    _applyStepFromStatus(booking.backendStatus);
  }
 
  void _applyStepFromStatus(String? statusRaw) {
    final String status = (statusRaw ?? '').toLowerCase();
    final int step = switch (status) {
      'matched' => 0,
      'on_the_way' => 1,
      'arrived' => 2,
      'in_progress' => 3,
      'completed' => 4,
      _ => 0,
    };
    setState(() => _currentStep = step);
  }
 
  @override
  void dispose() {
    _stepPulse.dispose();
    _realtime.unsubscribe();
    super.dispose();
  }
 
  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
 
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> job = _job ?? <String, dynamic>{
      'title': 'Your Job',
      'artisan': 'Artisan',
      'profession': 'Service provider',
      'eta': _etaLabel,
    };
    job['eta'] = _etaLabel;
 
    final String? workerId = job['worker_id'] as String?;
    final double? jobLat = (job['location_lat'] as num?)?.toDouble();
    final double? jobLng = (job['location_lng'] as num?)?.toDouble();
    final String? jobUuid =
        job['job_id'] as String? ?? job['jobId'] as String? ?? job['id'] as String?;
    final String status = (job['status'] as String? ?? '').toLowerCase();
    final bool canRate = status == 'completed';
    final bool workerCancelled =
        status == 'cancelled' && (job['cancelled_by'] as String?) == 'worker';

    if (!_loading && workerCancelled) {
      return Scaffold(
        backgroundColor: _T.surfaceBase,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.gutter,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_loadError != null) _buildErrorBanner(),
                _MiniHero(
                  height: 140,
                  child: _heroForStep(0),
                ),
                const SizedBox(height: 16),
                _buildJobInfoCard(job),
                const SizedBox(height: 20),
                _buildWorkerCancellationCard(job, jobUuid),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => ClientNavigation.goToBookingsTab(context),
                    child: Text(
                      'Back to bookings',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _T.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: _T.primary.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }
 
    return Scaffold(
      backgroundColor: _T.surfaceBase,
      appBar: _buildAppBar(context),
      body: _loading
          ? _buildLoader()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Error banner
                    if (_loadError != null) _buildErrorBanner(),
 
                    // ── Hero illustration (changes per step)
                    _MiniHero(
                      height: 140,
                      child: _heroForStep(_currentStep),
                    ),
                    const SizedBox(height: 16),
 
                    // ── Job info card
                    _buildJobInfoCard(job),
                    const SizedBox(height: 20),
 
                    // ── Map or placeholder
                    if (workerId != null && jobLat != null && jobLng != null)
                      _buildMapCard(
                          workerId: workerId, jobLat: jobLat, jobLng: jobLng)
                    else
                      _buildMapPlaceholder(),
 
                    const SizedBox(height: 20),
 
                    // ── Progress timeline
                    _buildSectionLabel('Job Progress'),
                    const SizedBox(height: 14),
                    _buildProgressTimeline(),
                    const SizedBox(height: 20),
 
                    // ── Artisan card
                    _buildSectionLabel('Your Artisan'),
                    const SizedBox(height: 14),
                    _buildArtisanDetailCard(job),
                    const SizedBox(height: 20),
 
                    // ── Action buttons
                    _buildActionRow(job, jobUuid, workerId),
                    const SizedBox(height: 16),
 
                    // ── Rate button
                    _buildRateButton(canRate),
                    const SizedBox(height: 12),
 
                    // ── View all bookings
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            ClientNavigation.goToBookingsTab(context),
                        child: Text(
                          'View all bookings',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _T.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: _T.primary.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
 
  // ---------------------------------------------------------------------------
  // AppBar
  // ---------------------------------------------------------------------------
 
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: const BoxDecoration(
          color: _T.surfaceBase,
          border: Border(
              bottom: BorderSide(color: Color(0x12000000), width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _T.surfaceCard,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                            color: _T.shadowDeep,
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: _T.textPrimary),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Live Tracking',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _T.textPrimary,
                      ),
                    ),
                  ),
                ),
                // Live indicator pill
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _T.successGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        color: _T.successGreen.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: _T.successGreen, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5E20),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  // ---------------------------------------------------------------------------
  // Loader
  // ---------------------------------------------------------------------------
 
  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: _T.primary,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 14),
          Text(
            'Loading tracking info…',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              color: _T.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
 
  // ---------------------------------------------------------------------------
  // Error banner
  // ---------------------------------------------------------------------------
 
  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _T.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _T.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: _T.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _loadError!,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                color: _T.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  // ---------------------------------------------------------------------------
  // Section label
  // ---------------------------------------------------------------------------
 
  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(width: 3, height: 16, color: _T.primary,
            margin: const EdgeInsets.only(right: 8)),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _T.textPrimary,
          ),
        ),
      ],
    );
  }
 
  // ---------------------------------------------------------------------------
  // Job info card
  // ---------------------------------------------------------------------------
 
  Widget _buildJobInfoCard(Map<String, dynamic> job) {
    final String pillLabel = _statusPillLabel(job['status'] as String?);
    final Color pillBg = _statusPillColor(job['status'] as String?);
    final Color pillText = _statusPillTextColor(job['status'] as String?);
 
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_T.primary, _T.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _T.primary.withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          // Decorative pattern top-right
          Positioned(
            top: -16,
            right: -16,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (job['title'] as String? ?? 'Your Job')
                                .toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job['artisan'] as String? ?? 'Artisan',
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            job['profession'] as String? ?? 'Service provider',
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        pillLabel,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: pillText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.12),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(
                        Icons.access_time_rounded, 'ETA', _etaLabel),
                    const SizedBox(width: 12),
                    if (job['phone'] != null)
                      _buildInfoChip(
                          Icons.phone_rounded, 'Phone', job['phone'] as String),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: Colors.white60),
                const SizedBox(width: 4),
                Text(label,
                    style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 10,
                        color: Colors.white60,
                        letterSpacing: 0.4)),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
 
  String _statusPillLabel(String? statusRaw) {
    return switch ((statusRaw ?? '').toLowerCase()) {
      'on_the_way' => 'On the Way',
      'arrived' => 'Arrived',
      'in_progress' => 'In Progress',
      'completed' => 'Completed',
      'cancelled' => 'Cancelled',
      'matched' => 'Confirmed',
      _ => 'Pending',
    };
  }
 
  Color _statusPillColor(String? statusRaw) {
    return switch ((statusRaw ?? '').toLowerCase()) {
      'completed' => _T.accentGold.withOpacity(0.2),
      'in_progress' => Colors.white.withOpacity(0.18),
      _ => Colors.white.withOpacity(0.14),
    };
  }
 
  Color _statusPillTextColor(String? statusRaw) {
    return switch ((statusRaw ?? '').toLowerCase()) {
      'completed' => _T.accentGold,
      _ => Colors.white,
    };
  }

  Widget _buildWorkerCancellationCard(Map<String, dynamic> job, String? jobUuid) {
    final String reason = (job['cancelled_reason'] as String? ?? '').trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _T.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _T.error.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: _T.error.withOpacity(0.12),
                child: Icon(Icons.error_outline_rounded, color: _T.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'The worker cancelled this booking',
                  style: AppTypography.titleMd.copyWith(
                    color: _T.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reason.isNotEmpty
                ? reason
                : 'You can reopen this same job and we will search for another available worker.',
            style: AppTypography.bodyMedium.copyWith(color: _T.textSecondary),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Request another worker',
            isLoading: _requestingAnotherWorker,
            isEnabled: !_requestingAnotherWorker && jobUuid != null && jobUuid.isNotEmpty,
            onPressed: () => _requestAnotherWorker(jobUuid),
          ),
        ],
      ),
    );
  }

  Future<void> _requestAnotherWorker(String? jobUuid) async {
    if (_requestingAnotherWorker || jobUuid == null || jobUuid.isEmpty) return;
    setState(() => _requestingAnotherWorker = true);
    try {
      final dynamic reopened = await _jobsService.requestAnotherWorker(jobUuid);
      if (!mounted) return;
      unawaited(Navigator.pushReplacementNamed(
        context,
        AppRoutes.findingArtisan,
        arguments: <String, dynamic>{
          'jobData': Map<String, dynamic>.from(reopened as Map),
        },
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessageFor(e, fallback: 'Could not request another worker.'))),
      );
    } finally {
      if (mounted) setState(() => _requestingAnotherWorker = false);
    }
  }
 
  // ---------------------------------------------------------------------------
  // Map card
  // ---------------------------------------------------------------------------
 
  Widget _buildMapCard({
    required String workerId,
    required double jobLat,
    required double jobLng,
  }) {
    return Container(
      decoration: _premiumCard(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.map_rounded, size: 16, color: _T.primary),
                const SizedBox(width: 6),
                const Text(
                  'Live Location',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _T.textPrimary,
                  ),
                ),
                const Spacer(),
                _LiveDot(),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: WorkerTrackingMap(
              workerId: workerId,
              jobLat: jobLat,
              jobLng: jobLng,
              onEtaChanged: (eta) => setState(() => _etaLabel = eta),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildMapPlaceholder() {
    return Container(
      height: 180,
      decoration: _premiumCard(color: const Color(0xFFFAF5F0)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_searching_rounded,
                size: 36, color: _T.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 10),
            Text(
              'Waiting for artisan location…',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                color: _T.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  // ---------------------------------------------------------------------------
  // Progress timeline
  // ---------------------------------------------------------------------------
 
  Widget _buildProgressTimeline() {
    return Container(
      decoration: _premiumCard(),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      child: Column(
        children: List.generate(_steps.length, (int index) {
          final Map<String, dynamic> step = _steps[index];
          final bool isCompleted = index <= _currentStep;
          final bool isCurrent = index == _currentStep;
          final bool isUpcoming = index > _currentStep;
 
          return Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Step node
                  AnimatedBuilder(
                    animation: _stepPulse,
                    builder: (_, child) {
                      final double pulse = isCurrent
                          ? (1.0 + _stepPulse.value * 0.12)
                          : 1.0;
                      return Transform.scale(scale: pulse, child: child);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? const LinearGradient(
                                colors: [_T.primary, _T.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isUpcoming
                            ? const Color(0xFFF0EBE5)
                            : null,
                        shape: BoxShape.circle,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                    color: _T.primary.withOpacity(0.30),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4))
                              ]
                            : isCompleted
                                ? [
                                    BoxShadow(
                                        color: _T.primary.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3))
                                  ]
                                : null,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: isCompleted
                            ? Colors.white
                            : _T.textSecondary.withOpacity(0.45),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          step['title'] as String,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 14,
                            fontWeight: isCurrent
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isCurrent
                                ? _T.primary
                                : isCompleted
                                    ? _T.textPrimary
                                    : _T.textSecondary.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step['description'] as String,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 12,
                            color: isUpcoming
                                ? _T.textSecondary.withOpacity(0.35)
                                : _T.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _T.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (index < _currentStep)
                    const Icon(Icons.check_rounded,
                        color: _T.primary, size: 18),
                ],
              ),
              if (index < _steps.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 0, bottom: 0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 2,
                        height: 38,
                        child: isCompleted && index < _currentStep
                            ? Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [_T.primary, _T.primaryDark],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFE8E0D8),
                              ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
 
  // ---------------------------------------------------------------------------
  // Artisan detail card
  // ---------------------------------------------------------------------------
 
  Widget _buildArtisanDetailCard(Map<String, dynamic> job) {
    final String? imageUrl = job['imageUrl'] as String?;
    final double? rating = (job['rating'] as num?)?.toDouble();
 
    return Container(
      decoration: _premiumCard(),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: <Widget>[
          // Avatar
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_T.primaryContainer, Color(0xFFF7E8E3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: _T.primary.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: imageUrl != null && imageUrl.startsWith('http')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_rounded,
                              color: _T.primary,
                              size: 36),
                        ),
                      )
                    : const Icon(Icons.person_rounded,
                        color: _T.primary, size: 36),
              ),
              // Online dot
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _T.successGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: _T.surfaceCard, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: _T.successGreen.withOpacity(0.4),
                          blurRadius: 6)
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  job['artisan'] as String? ?? 'Artisan',
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _T.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  job['profession'] as String? ?? 'Service provider',
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13,
                    color: _T.textSecondary,
                  ),
                ),
                if (rating != null) ...[
                  const SizedBox(height: 6),
                  _StarRating(rating: rating),
                ],
              ],
            ),
          ),
          // Verified badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: _T.accentGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: _T.accentGold.withOpacity(0.25), width: 1),
            ),
            child: Column(
              children: [
                const Icon(Icons.verified_rounded,
                    color: _T.accentGold, size: 18),
                const SizedBox(height: 2),
                Text(
                  'Verified',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _T.accentWarm,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  // ---------------------------------------------------------------------------
  // Action row (Call / Message)
  // ---------------------------------------------------------------------------
 
  Widget _buildActionRow(
      Map<String, dynamic> job, String? jobUuid, String? workerId) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _ActionButton(
            icon: Icons.phone_rounded,
            label: 'Call',
            isEnabled: job['phone'] != null,
            onTap: job['phone'] != null
                ? () => ClientNavigation.callPhone(
                    context, job['phone'] as String)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.chat_bubble_rounded,
            label: 'Message',
            isEnabled: jobUuid != null,
            onTap: jobUuid != null
                ? () => ClientNavigation.openChat(
                      context,
                      conversationId: jobUuid,
                      counterpartUserId:
                          job['counterpartUserId'] as String? ?? workerId ?? '',
                      counterpartName:
                          job['artisan'] as String? ?? 'Artisan',
                      jobId: jobUuid,
                      jobTitle: job['title'] as String?,
                    )
                : null,
          ),
        ),
      ],
    );
  }
 
  // ---------------------------------------------------------------------------
  // Rate button
  // ---------------------------------------------------------------------------
 
  Widget _buildRateButton(bool canRate) {
    return GestureDetector(
      onTap: canRate
          ? () => Navigator.pushNamed(context, AppRoutes.rateService,
              arguments: _job)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: canRate
              ? const LinearGradient(
                  colors: [_T.primary, _T.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: canRate ? null : const Color(0xFFE8E0D8),
          borderRadius: BorderRadius.circular(14),
          boxShadow: canRate
              ? [
                  BoxShadow(
                      color: _T.primary.withOpacity(0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              canRate ? Icons.star_rounded : Icons.hourglass_top_rounded,
              color: canRate ? _T.accentGold : _T.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              canRate ? 'Rate Your Experience' : 'Waiting for Completion',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: canRate ? Colors.white : _T.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------
 
class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}
 
class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
 
  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: _T.successGreen.withOpacity(0.4 + _ctrl.value * 0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Live',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _T.successGreen.withOpacity(0.7 + _ctrl.value * 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
 
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final VoidCallback? onTap;
 
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isEnabled,
    this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isEnabled ? _T.surfaceCard : const Color(0xFFF5F0EC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isEnabled ? _T.primary.withOpacity(0.25) : _T.borderSubtle,
            width: 1.2,
          ),
          boxShadow: isEnabled
              ? const [
                  BoxShadow(
                      color: _T.shadowMid,
                      blurRadius: 10,
                      offset: Offset(0, 3))
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isEnabled ? _T.primary : _T.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isEnabled
                    ? _T.primary
                    : _T.textSecondary.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final bool full = i < rating.floor();
          final bool half = !full && i < rating;
          return Icon(
            full
                ? Icons.star_rounded
                : half
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            size: 14,
            color: _T.accentGold,
          );
        }),
        const SizedBox(width: 5),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _T.textSecondary,
          ),
        ),
      ],
    );
  }
}
