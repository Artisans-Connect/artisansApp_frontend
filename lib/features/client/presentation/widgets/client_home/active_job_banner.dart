import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';
import 'package:artisans_app/features/client/presentation/models/client_booking.dart';

class ActiveJobBanner extends StatefulWidget {
  const ActiveJobBanner({
    super.key,
    required this.booking,
    required this.onViewJob,
    required this.onTrack,
  });

  final ClientBooking booking;
  final VoidCallback onViewJob;
  final VoidCallback onTrack;

  @override
  State<ActiveJobBanner> createState() => _ActiveJobBannerState();
}

class _ActiveJobBannerState extends State<ActiveJobBanner> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  BoxDecoration _card({
    Color color = DesignTokens.surfaceCard,
    double radius = DesignTokens.radiusXl,
    bool shadow = true,
  }) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: DesignTokens.borderSubtle),
        boxShadow: shadow
            ? const <BoxShadow>[
                BoxShadow(
                    color: DesignTokens.shadowDeep, blurRadius: 20, offset: Offset(0, 6)),
                BoxShadow(
                    color: DesignTokens.shadow, blurRadius: 4, offset: Offset(0, 2)),
              ]
            : null,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(color: DesignTokens.primary.withValues(alpha: 0.05)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: DesignTokens.successGreen.withValues(
                      alpha: 0.5 + _pulse.value * 0.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'JOB IN PROGRESS',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.primary,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.booking.title,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Row(
            children: <Widget>[
              const Icon(Icons.person_rounded,
                  size: 12, color: DesignTokens.textSecondary),
              const SizedBox(width: 4),
              Text(
                'With ${widget.booking.artisan}',
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12,
                  color: DesignTokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onViewJob,
                  child: const Text('All bookings'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onTrack,
                  child: const Text('Track live'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
