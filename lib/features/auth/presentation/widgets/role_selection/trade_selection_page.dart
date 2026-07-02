import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../../core/theme/design_tokens.dart';
import '../../../../../shared/widgets/app_input.dart';
import '../../../models/onboarding_session.dart';
import 'onboarding_atoms.dart';
import 'trade_chip.dart';

class TradeSelectionPage extends StatelessWidget {
  const TradeSelectionPage({
    super.key,
    required this.session,
    required this.isLoadingTrades,
    required this.totalDots,
    required this.currentDot,
    required this.customTradeController,
    required this.isResolvingTrade,
    required this.resolveMessage,
    required this.resolveSuccess,
    required this.lastQuery,
    required this.trades,
    required this.onResolveCustomTrade,
    required this.onTradeToggled,
    required this.onCustomTradeAdded,
    required this.onCustomTradeRemoved,
  });

  final OnboardingSession session;
  final bool isLoadingTrades;
  final int totalDots;
  final int currentDot;
  final TextEditingController customTradeController;
  final bool isResolvingTrade;
  final String? resolveMessage;
  final bool resolveSuccess;
  final String lastQuery;
  final List<TradeEntry> trades;
  final VoidCallback onResolveCustomTrade;
  final ValueChanged<String> onTradeToggled;
  final ValueChanged<String> onCustomTradeAdded;
  final ValueChanged<String> onCustomTradeRemoved;

  @override
  Widget build(BuildContext context) {
    final int selectedCount = session.selectedTrades.length;

    // Show loading state
    if (isLoadingTrades) {
      return Column(
        children: <Widget>[
          HeroHeader(
            icon: const Icon(
              PhosphorIcons.toolbox,
              color: DesignTokens.primary,
              size: 34,
            ),
            bgColor: DesignTokens.primaryTint12,
            title: 'What work\ndo you do?',
            subtitle:
                'Pick all your trades — clients match\nyou based on these.',
            totalDots: totalDots,
            currentDot: currentDot,
          ),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // Hero header
          HeroHeader(
            icon: const Icon(
              PhosphorIcons.toolbox,
              color: DesignTokens.primary,
              size: 34,
            ),
            bgColor: DesignTokens.primaryTint12,
            title: 'What work\ndo you do?',
            subtitle:
                'Pick all your trades — clients match\nyou based on these.',
            totalDots: totalDots,
            currentDot: currentDot,
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(DesignTokens.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Smart search bar at the top
                AppInput(
                  controller: customTradeController,
                  hint: "Search or describe what you do (e.g. I fix shoes)",
                  prefixIcon: PhosphorIcons.magnifyingGlass,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) {
                    if (!isResolvingTrade) onResolveCustomTrade();
                  },
                  suffixIcon: isResolvingTrade
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                DesignTokens.primary,
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            PhosphorIcons.arrowRight,
                            color: DesignTokens.primary,
                          ),
                          onPressed: onResolveCustomTrade,
                        ),
                ),
                if (resolveMessage != null) ...[
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: resolveSuccess
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMd),
                      border: Border.all(
                        color: resolveSuccess
                            ? const Color(0xFF81C784)
                            : const Color(0xFFE57373),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              resolveSuccess
                                  ? PhosphorIcons.checkCircle
                                  : PhosphorIcons.warningCircle,
                              color: resolveSuccess
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                resolveMessage!,
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 12,
                                  color: resolveSuccess
                                      ? const Color(0xFF1B5E20)
                                      : const Color(0xFFB71C1C),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (lastQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              final String formattedQuery = lastQuery
                                  .split(' ')
                                  .map((word) => word.isNotEmpty
                                      ? '${word[0].toUpperCase()}${word.substring(1)}'
                                      : '')
                                  .join(' ');
                              onCustomTradeAdded(formattedQuery);
                            },
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIcons.plusCircle,
                                  size: 14,
                                  color: resolveSuccess
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFC62828),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Add '$lastQuery' as custom trade",
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: resolveSuccess
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFC62828),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                Builder(
                  builder: (BuildContext context) {
                    final List<String> predefinedLabels =
                        trades.map((TradeEntry t) => t.label).toList();
                    final List<String> customTrades = session.selectedTrades
                        .where(
                            (String trade) => !predefinedLabels.contains(trade))
                        .toList();

                    if (customTrades.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 12),
                        const SectionLabel("Custom added trades"),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: customTrades.map((String trade) {
                            return Chip(
                              label: Text(
                                trade,
                                style: const TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: DesignTokens.primaryDark,
                                ),
                              ),
                              backgroundColor: DesignTokens.primaryTint08,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusMd),
                                side: const BorderSide(
                                    color: DesignTokens.primaryTint12),
                              ),
                              deleteIcon: const Icon(
                                PhosphorIcons.x,
                                size: 14,
                                color: DesignTokens.primary,
                              ),
                              onDeleted: () => onCustomTradeRemoved(trade),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),
                const SectionLabel('All trades'),

                // 2-column icon card grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                  ),
                  itemCount: trades.length,
                  itemBuilder: (BuildContext context, int i) {
                    final TradeEntry entry = trades[i];
                    final bool selected =
                        session.selectedTrades.contains(entry.label);
                    return TradeChip(
                      label: entry.label,
                      icon: entry.icon,
                      selected: selected,
                      onTap: () => onTradeToggled(entry.label),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Selected count strip
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: selectedCount > 0
                      ? Container(
                          key: ValueKey<int>(selectedCount),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: DesignTokens.goldTint12,
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusMd),
                            border: Border.all(
                                color: DesignTokens.accentGold, width: 1),
                          ),
                          child: Row(
                            children: <Widget>[
                              const Icon(PhosphorIcons.checkCircle,
                                  color: DesignTokens.accentWarm, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "$selectedCount trade${selectedCount > 1 ? 's' : ''} selected — add more any time from settings.",
                                  style: const TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 12,
                                    color: DesignTokens.accentWarm,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
