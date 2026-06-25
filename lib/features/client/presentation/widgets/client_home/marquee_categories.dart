import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../category_chip.dart';

class MarqueeCategoriesList extends StatefulWidget {
  const MarqueeCategoriesList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.selectedCategory,
    required this.categoryIcon,
    required this.onCategorySelected,
    required this.onSeeMore,
  });

  final List<Map<String, dynamic>> categories;
  final String selectedCategoryId;
  final String selectedCategory;
  final IconData Function(Map<String, dynamic>) categoryIcon;
  final Function(String id, String label) onCategorySelected;
  final VoidCallback onSeeMore;

  @override
  State<MarqueeCategoriesList> createState() => _MarqueeCategoriesListState();
}

class _MarqueeCategoriesListState extends State<MarqueeCategoriesList> {
  late final ScrollController _scrollController;
  bool _isUserInteracting = false;
  Timer? _resumeTimer;

  // A high multiplier gives us plenty of room for an infinite scrolling illusion
  static const int _loopMultiplier = 2000;

  @override
  void initState() {
    super.initState();
    // Start at 0 instead of forcing a massive offset before layout happens
    _scrollController = ScrollController();

    // CRITICAL: Wait for the layout frame to paint, then kick off the smooth scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // Determines if the marquee should actively scroll
  bool get _shouldAnimate {
    final bool hasSelection =
        widget.selectedCategoryId.isNotEmpty || widget.selectedCategory.isNotEmpty;
    return !hasSelection && !_isUserInteracting;
  }

void _startAutoScroll() {
  if (!mounted || !_shouldAnimate || !_scrollController.hasClients) return;

  final double maxScroll = _scrollController.position.maxScrollExtent;
  final double currentScroll = _scrollController.offset;
  final double remainingDistance = maxScroll - currentScroll;

  // Speed in pixels per second — 80 is a comfortable marquee pace.
  // Increase to 120–150 for faster scrolling.
  const double pixelsPerSecond = 80.0;
  final int durationMs = (remainingDistance / pixelsPerSecond * 1000).round();

  if (durationMs > 0) {
    _scrollController
        .animateTo(
      maxScroll,
      duration: Duration(milliseconds: durationMs),
      curve: Curves.linear,
    )
        .then((_) {
      if (mounted && _shouldAnimate) {
        _scrollController.jumpTo(0);
        _startAutoScroll();
      }
    });
  }
}

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      setState(() {
        _isUserInteracting = true;
      });
      _resumeTimer?.cancel();
      // Gracefully halts the active programmatic animation so it doesn't fight user drag
      _scrollController.position.hold(() {}); 
    } else if (notification is ScrollEndNotification) {
      _resumeTimer?.cancel();
      _resumeTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _isUserInteracting = false;
          });
          _startAutoScroll();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();

    final List<Map<String, dynamic>> cats = widget.categories;
    final int baseLength = cats.length + 1; // +1 for 'See more'
    final int totalItems = baseLength * _loopMultiplier;

    return SizedBox(
      height: 46,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          _handleScrollNotification(notification);
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: totalItems,
          itemBuilder: (BuildContext context, int index) {
            final int actualIndex = index % baseLength;

            if (actualIndex == cats.length) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CategoryChip(
                  label: 'See more',
                  icon: Icons.arrow_forward_rounded,
                  isSelected: false,
                  onTap: widget.onSeeMore,
                ),
              );
            }

            final Map<String, dynamic> cat = cats[actualIndex];
            final String catId = (cat['id'] ?? '').toString();
            final String label = (cat['name'] ?? cat['label'] ?? 'Service').toString();
            
            final bool selected = catId.isNotEmpty
                ? widget.selectedCategoryId == catId
                : widget.selectedCategory == label;

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CategoryChip(
                label: label,
                icon: widget.categoryIcon(cat),
                isSelected: selected,
                onTap: () => widget.onCategorySelected(catId, label),
              ),
            );
          },
        ),
      ),
    );
  }
}