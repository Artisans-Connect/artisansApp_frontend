import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/negotiation_service.dart';
import '../../../../core/services/negotiation_realtime_service.dart';
import '../../../../core/session/app_user_session.dart';
import '../../../../shared/models/negotiation.dart';
import '../../../../shared/widgets/negotiation_chat_sheet.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/services/workers_service.dart';
import '../../../../core/theme/index.dart';
import '../../../../shared/presentation/navigation/shared_route_args.dart';
import '../../../../shared/presentation/screens/chat_detail_screen.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/job_site_map.dart';
import '../../../client/presentation/navigation/client_navigation.dart';
import '../models/worker_job.dart';
import '../state/worker_session_state.dart';
import '../widgets/client_contact_row.dart';
import '../widgets/elapsed_timer_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/worker_phase_stepper.dart';
import 'worker_completion_form_screen.dart';
import '../../../trust_safety/presentation/widgets/safety_help_bottom_sheet.dart';

class WorkerActiveInProgressScreen extends StatefulWidget {
  const WorkerActiveInProgressScreen({super.key, required this.job});
  final WorkerJob job;

  @override
  State<WorkerActiveInProgressScreen> createState() =>
      _WorkerActiveInProgressScreenState();
}

class _WorkerActiveInProgressScreenState
    extends State<WorkerActiveInProgressScreen> {
  final WorkersService _workersService = WorkersService();
  bool _isCancelling = false;

  Map<String, dynamic>? _activeExtraCharge;
  bool _loadingExtraCharge = true;
  RealtimeChannel? _extraChargeChannel;

  @override
  void initState() {
    super.initState();
    _fetchExtraCharge();
    _subscribeExtraCharge();
  }

  String? _hasOpenedLiveBargainingSheetKey;
  final NegotiationRealtimeService _negotiationRealtime = NegotiationRealtimeService();

  @override
  void dispose() {
    _extraChargeChannel?.unsubscribe();
    _negotiationRealtime.unsubscribeJob();
    super.dispose();
  }

  Future<void> _fetchExtraCharge() async {
    try {
      final List<Negotiation> negs = await NegotiationService.instance.getJobNegotiations(widget.job.id);
      final Negotiation? activeNeg = negs.cast<Negotiation?>().firstWhere(
        (n) => n != null && (n.status == NegotiationStatus.open || n.status == NegotiationStatus.accepted || n.status == NegotiationStatus.paid),
        orElse: () => null,
      );

      final Negotiation? openNeg = negs.cast<Negotiation?>().firstWhere(
        (n) => n != null && n.status == NegotiationStatus.open,
        orElse: () => null,
      );

      if (mounted) {
        setState(() {
          _activeExtraCharge = activeNeg != null ? {
            'id': activeNeg.id,
            'status': activeNeg.status.name,
            'requested_amount': activeNeg.agreedAmount ?? activeNeg.initialAmount,
            'description': activeNeg.description,
            'negotiation': activeNeg,
          } : null;
          _loadingExtraCharge = false;
        });

        final String currentUserId = AppUserSession.instance.currentUser?.id ?? '';
        final NegotiationRound? lastRound = openNeg?.rounds.isNotEmpty == true ? openNeg!.rounds.last : null;
        final bool isCounterpartyTurnToRespond = lastRound != null && lastRound.proposedBy != currentUserId;

        if (openNeg != null && openNeg.status == NegotiationStatus.open && isCounterpartyTurnToRespond) {
          final String currentKey = '${openNeg.id}_${openNeg.rounds.length}';
          if (_hasOpenedLiveBargainingSheetKey != currentKey) {
            _hasOpenedLiveBargainingSheetKey = currentKey;
            NegotiationChatSheet.show(
              context,
              negotiation: openNeg,
              onStatusChanged: () {
                _fetchExtraCharge();
              },
            );
          }
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingExtraCharge = false);
      }
    }
  }

  void _subscribeExtraCharge() {
    _negotiationRealtime.subscribeToJobNegotiations(
      widget.job.id,
      onUpdate: () {
        _fetchExtraCharge();
      },
    );
  }

  Future<void> _showExtraChargeDialog() async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    bool submitting = false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request Additional Extra Charge', style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 18, fontWeight: FontWeight.bold, color: DesignTokens.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    'Enter an additional amount needed for extra materials or expanded scope. This will be added on top of your original job escrow upon client approval.',
                    style: TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 12, color: DesignTokens.textMuted),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Additional Amount (GHS)',
                      hintText: '0.00',
                      prefixText: '+ GHS ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Reason for Extra Charge',
                      hintText: 'e.g. Bought extra 5m copper cable and junction box',
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: submitting
                      ? null
                      : () async {
                          final double? amount = double.tryParse(amountController.text);
                          if (amount == null || amount <= 0) {
                            AppToast.showInfo(context, 'Please enter a valid amount.');
                            return;
                          }
                          setModalState(() => submitting = true);
                          try {
                            await NegotiationService.instance.createNegotiation(
                              jobId: widget.job.id,
                              type: 'extra_charge',
                              initialAmount: amount,
                              description: descController.text.trim(),
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            _fetchExtraCharge();
                            if (mounted) {
                              AppToast.showPayment(context, '⚡ Extra charge request (+GHS ${amount.toStringAsFixed(2)}) sent to client!');
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              AppToast.showError(context, e, fallback: 'Failed to request extra charge.');
                            }
                          } finally {
                            setModalState(() => submitting = false);
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Submit Extra Charge',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildExtraChargeWidget() {
    if (_loadingExtraCharge) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_activeExtraCharge == null) {
      return OutlinedButton.icon(
        onPressed: _showExtraChargeDialog,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: DesignTokens.primary),
        ),
        icon: const Icon(PhosphorIcons.plusCircle, size: 20, color: DesignTokens.primary),
        label: const Text(
          'Request Extra Charge',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: DesignTokens.primary,
          ),
        ),
      );
    }

    final double amount = double.tryParse(_activeExtraCharge!['requested_amount'].toString()) ?? 0.0;
    final String status = _activeExtraCharge!['status'].toString();
    final String desc = _activeExtraCharge!['description']?.toString() ?? '';
    final Negotiation negotiation = _activeExtraCharge!['negotiation'] as Negotiation;

    Color cardColor = DesignTokens.warmSurface;
    Color borderColor = DesignTokens.warmBorder;
    Widget statusContent;

    if (status == 'open') {
      statusContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              const Icon(Icons.swap_horiz_rounded, color: DesignTokens.accentWarm, size: 20),
              const SizedBox(width: 8),
              Text(
                negotiation.type == NegotiationType.completionAdjustment
                    ? '⚡ Price Bargaining in Progress'
                    : 'Extra Charge Proposal',
                style: const TextStyle(fontWeight: FontWeight.bold, color: DesignTokens.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Proposed GHS ${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          if (desc.isNotEmpty) Text('Reason: $desc', style: const TextStyle(fontSize: 12, color: DesignTokens.textMuted)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              NegotiationChatSheet.show(
                context,
                negotiation: negotiation,
                onStatusChanged: () {
                  _fetchExtraCharge();
                },
              );
            },
            icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white),
            label: Text(
              negotiation.type == NegotiationType.completionAdjustment
                  ? 'Open Live Bargaining Chat'
                  : 'Review & Respond to Extra Charge',
              style: const TextStyle(fontFamily: AppTypography.fontFamily, fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      );
    } else if (status == 'accepted') {
      statusContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: DesignTokens.successGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Extra Charge Approved: GHS ${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: DesignTokens.successGreen),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'This extra charge will be collected in the final job completion settlement.',
            style: TextStyle(fontSize: 12, color: DesignTokens.textMuted),
          ),
        ],
      );
    } else if (status == 'paid') {
      statusContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, color: DesignTokens.successGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Extra Charge Paid: GHS ${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: DesignTokens.successGreen),
              ),
            ],
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: statusContent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final WorkerSessionState session = WorkerScope.of(context);
    final WorkerJob job = widget.job;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: DesignTokens.successGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'WORK IN PROGRESS',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: DesignTokens.successGreen,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              job.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DesignTokens.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: DesignTokens.primary),
            tooltip: 'Safety & Support',
            onPressed: () {
              SafetyHelpBottomSheet.show(
                context,
                bookingId: job.id,
                otherUserId: job.clientId,
                otherUserName: job.clientName,
                jobTitle: job.title,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Stepper Header
              const WorkerPhaseStepper(currentPhase: WorkerJobPhase.inProgress),
              const SizedBox(height: DesignTokens.sm),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Live Timer Card
                    ElapsedTimerCard(startedAt: job.startedAt),

                    const SizedBox(height: DesignTokens.md),

                    // Client Contact Card
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.md),
                      decoration: BoxDecoration(
                        color: DesignTokens.surfaceCard,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                        border: Border.all(color: DesignTokens.borderSubtle),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: DesignTokens.shadowMid,
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: DesignTokens.primaryContainer,
                                child: Text(
                                  job.clientName.isNotEmpty
                                      ? job.clientName.substring(0, 1).toUpperCase()
                                      : 'C',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: DesignTokens.primary,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: DesignTokens.successGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: DesignTokens.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  job.clientName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: DesignTokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Client on Site',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 12,
                                    color: DesignTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ClientContactRow(
                            onMessage: () => _openMessage(context, job),
                            onCall: () => _callClient(context, job),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignTokens.md),

                    // Site Map if Available
                    if (job.hasServiceLocation) ...<Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                        child: JobSiteMap(
                          latitude: job.latitude,
                          longitude: job.longitude,
                          label: job.addressLabel,
                          height: 180,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.md),
                    ],

                    // Job Details Summary
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.lg),
                      decoration: BoxDecoration(
                        color: DesignTokens.surfaceCard,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                        border: Border.all(color: DesignTokens.borderSubtle),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: DesignTokens.shadow,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          _DetailRow(
                            icon: PhosphorIcons.mapPin,
                            label: 'BOOKING LOCATION',
                            value: job.addressLabel,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: DesignTokens.sm + 4),
                            child: Divider(height: 1, color: DesignTokens.borderSubtle),
                          ),
                          _DetailRow(
                            icon: PhosphorIcons.fileText,
                            label: 'REQUEST DETAILS',
                            value: job.description.isNotEmpty
                                ? job.description
                                : 'No extra instructions specified.',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignTokens.xl),

                    // Primary Complete Button
                    GradientButton(
                      label: 'Mark Work as Complete  ✓',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => WorkerCompletionFormScreen(
                              job: job,
                              onCompletionSubmitted: () {
                                unawaited(session.loadActiveJob());
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: DesignTokens.sm),

                    _buildExtraChargeWidget(),

                    const SizedBox(height: DesignTokens.sm),

                    // Cancel Booking
                    Center(
                      child: TextButton.icon(
                        onPressed: _isCancelling
                            ? null
                            : () => _confirmCancel(context, session, job),
                        icon: _isCancelling
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: DesignTokens.error,
                                ),
                              )
                            : Icon(
                                PhosphorIcons.xCircle,
                                size: 16,
                                color: DesignTokens.error,
                              ),
                        label: Text(
                          _isCancelling ? 'Cancelling booking...' : 'Cancel booking',
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.error,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.md),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMessage(BuildContext context, WorkerJob job) {
    final String clientId = job.clientId ?? '';
    if (clientId.isEmpty) {
      AppToast.showInfo(
        context,
        'Client chat is not available for this booking.',
      );
      return;
    }
    Navigator.pushNamed(
      context,
      ChatDetailScreen.routeName,
      arguments: ChatDetailArgs(
        conversationId: job.id,
        jobId: job.id,
        counterpartUserId: clientId,
        counterpartName: job.clientName,
        counterpartPhone: job.clientPhone,
        jobTitle: job.title,
      ),
    );
  }

  Future<void> _callClient(BuildContext context, WorkerJob job) async {
    final String phone = job.clientPhone ?? '';
    await ClientNavigation.callPhone(context, phone);
  }

  Future<void> _confirmCancel(
    BuildContext context,
    WorkerSessionState session,
    WorkerJob job,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel booking?'),
        content: const Text(
          'The client will be notified and can request another worker.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep booking'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cancel booking',
              style: TextStyle(color: DesignTokens.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isCancelling = true);
    try {
      await _workersService.cancelJob(job.id);
      if (!context.mounted) return;
      session.cancelActiveJob();
      AppToast.showInfo(context, 'Booking cancelled. The client was notified.');
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(context, e, fallback: 'Could not cancel booking.');
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines,
  });

  final IconData icon;
  final String label;
  final String value;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: DesignTokens.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: DesignTokens.primary, size: 16),
        ),
        const SizedBox(width: DesignTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: DesignTokens.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textPrimary,
                  height: 1.4,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
