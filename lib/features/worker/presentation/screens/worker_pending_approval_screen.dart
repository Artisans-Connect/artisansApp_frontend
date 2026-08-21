import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/services/workers_service.dart';
import 'package:artisans_app/core/theme/index.dart';
import 'package:artisans_app/shared/widgets/app_toast.dart';
import 'package:artisans_app/shared/models/worker_job.dart';
import 'package:artisans_app/features/worker/presentation/state/worker_session_state.dart';
import 'package:artisans_app/features/worker/presentation/widgets/worker_phase_stepper.dart';
import 'package:artisans_app/features/worker/presentation/screens/worker_completion_form_screen.dart';

class WorkerPendingApprovalScreen extends StatefulWidget {
  const WorkerPendingApprovalScreen({super.key, required this.job});

  final WorkerJob job;

  @override
  State<WorkerPendingApprovalScreen> createState() =>
      _WorkerPendingApprovalScreenState();
}

class _WorkerPendingApprovalScreenState
    extends State<WorkerPendingApprovalScreen> {
  final WorkersService _workersService = WorkersService();
  bool _isCancelling = false;

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
      if (!mounted) return;
      session.cancelActiveJob();
      AppToast.showInfo(context, 'Booking cancelled. The client was notified.');
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not cancel booking.');
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
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
                color: DesignTokens.accentGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'AWAITING APPROVAL',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.secondaryContainer,
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Stepper
              const WorkerPhaseStepper(
                currentPhase: WorkerJobPhase.pendingApproval,
              ),
              const SizedBox(height: DesignTokens.sm),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Reassuring Banner Card
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.lg),
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
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: DesignTokens.successGreen.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                PhosphorIcons.checkCircleFill,
                                size: 32,
                                color: DesignTokens.successGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: DesignTokens.md),
                          const Text(
                            'Completion Report Sent!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: DesignTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.xs + 2),
                          Text(
                            'Your job completion details have been delivered to ${job.clientName}. Once approved, funds will be immediately released to your wallet.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              color: DesignTokens.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignTokens.md),

                    // Proposed Payout Card
                    if (job.grossAmount != null || job.earnedAmount != null) ...<Widget>[
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.lg),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              DesignTokens.primary.withValues(alpha: 0.06),
                              DesignTokens.surfaceCard,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                          border: Border.all(
                            color: DesignTokens.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'PROPOSED PAYOUT',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: DesignTokens.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'GH₵ ${(job.earnedAmount ?? job.grossAmount ?? 0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: DesignTokens.primary,
                              ),
                            ),
                            if (job.baseRate != null) ...<Widget>[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: DesignTokens.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Base Pay: GH₵ ${job.baseRate!.toStringAsFixed(2)} • Distance: GH₵ ${(job.distanceCost ?? 0).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: DesignTokens.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.md),
                    ],

                    // Client & Location Details Card
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.lg),
                      decoration: BoxDecoration(
                        color: DesignTokens.surfaceCard,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                        border: Border.all(color: DesignTokens.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                PhosphorIcons.user,
                                size: 16,
                                color: DesignTokens.primary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'CLIENT',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: DesignTokens.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.clientName,
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: DesignTokens.textPrimary,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: DesignTokens.sm),
                            child: Divider(height: 1, color: DesignTokens.borderSubtle),
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                PhosphorIcons.mapPin,
                                size: 16,
                                color: DesignTokens.primary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'LOCATION',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: DesignTokens.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.addressLabel,
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13,
                              color: DesignTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignTokens.xl),

                    // Edit Completion Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: DesignTokens.borderSubtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => WorkerCompletionFormScreen(
                              job: job,
                              onCompletionSubmitted: () {
                                unawaited(WorkerScope.read(context).loadActiveJob());
                              },
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        PhosphorIcons.pencilSimple,
                        size: 18,
                        color: DesignTokens.primary,
                      ),
                      label: const Text(
                        'Edit Completion Details',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: DesignTokens.sm),

                    // Cancel Booking Option
                    Center(
                      child: TextButton(
                        onPressed: _isCancelling
                            ? null
                            : () => _confirmCancel(context, session, job),
                        child: Text(
                          _isCancelling ? 'Cancelling...' : 'Cancel Booking',
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
}
