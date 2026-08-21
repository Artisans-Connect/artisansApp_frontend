import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';

class PulseDot extends StatelessWidget {
  const PulseDot({super.key, required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: online ? DesignTokens.successGreen : DesignTokens.textMuted,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Premium availability toggle card.
class AvailabilityCard extends StatelessWidget {
  const AvailabilityCard({
    super.key,
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
              PulseDot(online: isAvailable),
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
              if (lastCheckedAt != null)
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
