import 'package:flutter/material.dart';

import '../../../../../core/theme/design_tokens.dart';

// ---------------------------------------------------------------------------
// MiniHero – gradient container used as a step illustration wrapper
// ---------------------------------------------------------------------------

class MiniHero extends StatelessWidget {
  final Widget child;
  final double height;
  const MiniHero({super.key, required this.child, this.height = 112});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0E6), Color(0xFFFFF8F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// heroForStep – top-level helper returning a StepHero for a given step index
// ---------------------------------------------------------------------------

Widget heroForStep(int step) => StepHero(step: step);

// ---------------------------------------------------------------------------
// StepHero – animated pulsing icon + title + subtitle for each timeline step
// ---------------------------------------------------------------------------

class StepHero extends StatefulWidget {
  final int step;
  const StepHero({super.key, required this.step});

  @override
  State<StepHero> createState() => _StepHeroState();
}

class _StepHeroState extends State<StepHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StepHeroData data = _dataForStep(widget.step);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ScaleTransition(
          scale: _pulse,
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: DesignTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          data.subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            color: DesignTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  StepHeroData _dataForStep(int step) {
    return switch (step) {
      1 => const StepHeroData(
          icon: Icons.directions_bike_rounded,
          title: 'Artisan on the Way',
          subtitle: 'Track live location below',
          color: DesignTokens.accentGold,
        ),
      2 => const StepHeroData(
          icon: Icons.location_on_rounded,
          title: 'Artisan Arrived',
          subtitle: 'Service will begin shortly',
          color: DesignTokens.successGreen,
        ),
      3 => const StepHeroData(
          icon: Icons.settings_rounded,
          title: 'Work in Progress',
          subtitle: 'Your job is being handled',
          color: DesignTokens.primary,
        ),
      4 => const StepHeroData(
          icon: Icons.celebration_rounded,
          title: 'Job Completed',
          subtitle: 'Share your experience with a rating',
          color: DesignTokens.primary,
        ),
      _ => const StepHeroData(
          icon: Icons.check_circle_rounded,
          title: 'Booking Confirmed',
          subtitle: 'Your artisan is getting ready',
          color: DesignTokens.primary,
        ),
    };
  }
}

class StepHeroData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const StepHeroData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

// ---------------------------------------------------------------------------
// SectionHeader – small vertical bar + bold title
// ---------------------------------------------------------------------------

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          margin: const EdgeInsets.only(right: 8),
          color: DesignTokens.primary,
        ),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: DesignTokens.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// LiveDot – pulsing green "Live" indicator
// ---------------------------------------------------------------------------

class LiveDot extends StatefulWidget {
  const LiveDot({super.key});

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot>
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
              color: DesignTokens.successGreen.withValues(alpha: 0.4 + _ctrl.value * 0.6),
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
              color: DesignTokens.successGreen.withValues(alpha: 0.7 + _ctrl.value * 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ActionButton – Call / Message buttons
// ---------------------------------------------------------------------------

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
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
          color: isEnabled ? DesignTokens.surfaceCard : const Color(0xFFF5F0EC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isEnabled ? DesignTokens.primary.withValues(alpha: 0.25) : DesignTokens.borderSubtle,
            width: 1.2,
          ),
          boxShadow: isEnabled
              ? const [
                  BoxShadow(
                      color: DesignTokens.shadowMid,
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
              color: isEnabled ? DesignTokens.primary : DesignTokens.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isEnabled
                    ? DesignTokens.primary
                    : DesignTokens.textSecondary.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// StarRating – row of star icons + numeric label
// ---------------------------------------------------------------------------

class StarRating extends StatelessWidget {
  final double rating;
  const StarRating({super.key, required this.rating});

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
            color: DesignTokens.accentGold,
          );
        }),
        const SizedBox(width: 5),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: DesignTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}
