import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';

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

class ArtisanSkeleton extends StatelessWidget {
  const ArtisanSkeleton({super.key, required this.opacity});
  final double opacity;
 
  @override
  Widget build(BuildContext context) {
    final Color base =
        Color.lerp(const Color(0xFFF0EBE5), const Color(0xFFFFF0E6), opacity)!;
    return Container(
      width: 190,
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: base,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DesignTokens.radiusXl)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _bar(110, 12, base),
                const SizedBox(height: 7),
                _bar(75, 10, base),
                const SizedBox(height: 10),
                _bar(90, 10, base),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _bar(double width, double height, Color color) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      );
}

class SkeletonRow extends StatefulWidget {
  const SkeletonRow({super.key});

  @override
  State<SkeletonRow> createState() => _SkeletonRowState();
}
 
class _SkeletonRowState extends State<SkeletonRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
 
  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(right: 14),
            child: ArtisanSkeleton(opacity: _anim.value),
          ),
        ),
      ),
    );
  }
}

class EmptyArtisans extends StatelessWidget {
  const EmptyArtisans({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: _card(
          color: const Color(0xFFFAF5F0), shadow: false),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.people_outline_rounded,
              size: 34,
              color: DesignTokens.textSecondary.withValues(alpha: 0.35)),
          const SizedBox(height: 10),
          Text(
            'No artisans match your search',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              color: DesignTokens.textSecondary.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
