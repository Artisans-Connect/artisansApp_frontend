import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';
import 'package:artisans_app/shared/widgets/search_bar.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({
    super.key,
    required this.greeting,
    required this.name,
    this.searchQuery = '',
    this.isParsingIntent = false,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });

  final String greeting;
  final String name;
  final String searchQuery;
  final bool isParsingIntent;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[DesignTokens.primary, DesignTokens.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: DesignTokens.primary.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      greeting.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white60,
                        letterSpacing: 0.9,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.handyman_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            ),
            child: const Text(
              'What do you need fixed today?',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Embedded Search Bar
          CustomSearchBar(
            hintText: 'Search artisans, plumbing, electrical...',
            isLoading: isParsingIntent,
            showAiButton: true,
            onChanged: onSearchChanged,
            onSearch: onSearchSubmitted,
            onAiTap: onSearchSubmitted,
          ),
        ],
      ),
    );
  }
}
