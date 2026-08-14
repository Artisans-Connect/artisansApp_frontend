import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/index.dart';
import '../models/worker_ui_contracts.dart';
import '../state/worker_session_state.dart';
import '../widgets/gradient_button.dart';

class WorkerActiveEmptyScreen extends StatelessWidget {
  const WorkerActiveEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkerSessionState session = WorkerScope.of(context);
    final bool isOnline = session.availabilityStatus.isOnline;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Active Booking',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: DesignTokens.primary,
          ),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () async {
              await session.setAvailable(!isOnline);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: DesignTokens.gutter),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isOnline
                    ? DesignTokens.successGreen.withValues(alpha: 0.12)
                    : DesignTokens.offlineSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isOnline
                      ? DesignTokens.successGreen.withValues(alpha: 0.3)
                      : DesignTokens.borderSubtle,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isOnline ? DesignTokens.successGreen : DesignTokens.textMuted,
                      shape: BoxShape.circle,
                      boxShadow: isOnline
                          ? <BoxShadow>[
                              BoxShadow(
                                color: DesignTokens.successGreen.withValues(alpha: 0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? 'ONLINE' : 'OFFLINE',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isOnline ? DesignTokens.successGreen : DesignTokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.gutter,
            vertical: DesignTokens.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Main Reassuring Status Card
              Container(
                padding: const EdgeInsets.all(DesignTokens.xl),
                decoration: BoxDecoration(
                  color: DesignTokens.surfaceCard,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                  border: Border.all(color: DesignTokens.borderSubtle),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: DesignTokens.shadowMid,
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    // Ambient Icon Container
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            DesignTokens.primary.withValues(alpha: 0.12),
                            DesignTokens.primaryDark.withValues(alpha: 0.04),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: DesignTokens.primary.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          PhosphorIcons.briefcase,
                          size: 38,
                          color: DesignTokens.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.lg),
                    const Text(
                      'No Active Booking Right Now',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.sm),
                    Text(
                      isOnline
                          ? 'You are online and visible to nearby clients. New booking requests will appear here immediately.'
                          : 'You are currently offline. Switch your status to Online to start receiving booking requests.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        color: DesignTokens.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DesignTokens.lg),

              // Reassurance & Tips Section
              Container(
                padding: const EdgeInsets.all(DesignTokens.lg),
                decoration: BoxDecoration(
                  color: DesignTokens.warmSurface,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                  border: Border.all(color: DesignTokens.warmBorder.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          PhosphorIcons.lightbulb,
                          size: 18,
                          color: DesignTokens.primary,
                        ),
                        const SizedBox(width: DesignTokens.sm),
                        const Text(
                          'How Bookings Work',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: DesignTokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.md),
                    const _TipItem(
                      icon: PhosphorIcons.bellRinging,
                      title: 'Instant Job Dispatch',
                      description: 'Clients in your service area can send direct booking requests to your phone.',
                    ),
                    const SizedBox(height: DesignTokens.sm + 4),
                    const _TipItem(
                      icon: PhosphorIcons.shieldCheck,
                      title: 'Secured Escrow Payments',
                      description: 'Funds are securely reserved before you travel to the job location.',
                    ),
                    const SizedBox(height: DesignTokens.sm + 4),
                    const _TipItem(
                      icon: PhosphorIcons.navigationArrow,
                      title: 'Turn-by-Turn Directions',
                      description: 'Get precise GPS routes to the client\'s location right inside the app.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DesignTokens.xl),

              // Action Button
              GradientButton(
                label: 'Browse Available Jobs  →',
                onPressed: session.goToExplore,
              ),
              const SizedBox(height: DesignTokens.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

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
          child: Icon(
            icon,
            size: 16,
            color: DesignTokens.primary,
          ),
        ),
        const SizedBox(width: DesignTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  color: DesignTokens.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}