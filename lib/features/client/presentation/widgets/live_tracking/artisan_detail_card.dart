import 'package:flutter/material.dart';

import '../../../../../core/theme/design_tokens.dart';
import 'tracking_atoms.dart';

// ---------------------------------------------------------------------------
// ArtisanDetailCard – avatar, name, profession, rating, verified badge
// ---------------------------------------------------------------------------

class ArtisanDetailCard extends StatelessWidget {
  final Map<String, dynamic> job;

  const ArtisanDetailCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = job['imageUrl'] as String?;
    final double? rating = (job['rating'] as num?)?.toDouble();
    final bool isVerified = job['worker_is_verified'] == true ||
        job['isVerified'] == true ||
        job['verified'] == true;

    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
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
                    colors: [DesignTokens.primaryContainer, Color(0xFFF7E8E3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: DesignTokens.primary.withValues(alpha: 0.15),
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
                              color: DesignTokens.primary,
                              size: 36),
                        ),
                      )
                    : const Icon(Icons.person_rounded,
                        color: DesignTokens.primary, size: 36),
              ),
              // Online dot
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: DesignTokens.successGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: DesignTokens.surfaceCard, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: DesignTokens.successGreen.withValues(alpha: 0.4),
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
                    color: DesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  job['profession'] as String? ?? 'Service provider',
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13,
                    color: DesignTokens.textSecondary,
                  ),
                ),
                if (rating != null) ...[
                  const SizedBox(height: 6),
                  StarRating(rating: rating),
                ],
              ],
            ),
          ),
          if (isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: DesignTokens.accentGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: DesignTokens.accentGold.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.verified_rounded,
                      color: DesignTokens.accentGold, size: 18),
                  const SizedBox(height: 2),
                  Text(
                    'Verified',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.accentWarm,
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
}
