import 'package:flutter/material.dart';
import '../../../../../core/theme/design_tokens.dart';

enum ProfileTab { about, gallery, reviews }

class ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  const ProfileTabBarDelegate({
    required this.activeTab,
    required this.onTabChanged,
  });
 
  final ProfileTab activeTab;
  final ValueChanged<ProfileTab> onTabChanged;
 
  static const double _height = 48;
 
  @override
  double get minExtent => _height;
 
  @override
  double get maxExtent => _height;
 
  @override
  bool shouldRebuild(ProfileTabBarDelegate old) =>
      old.activeTab != activeTab;
 
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        border: const Border(
          bottom: BorderSide(color: DesignTokens.borderSubtle),
        ),
        boxShadow: overlapsContent
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withAlpha((0.06 * 255).round()),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: <Widget>[
          ProfileTabWidget(
            label: 'About',
            active: activeTab == ProfileTab.about,
            onTap: () => onTabChanged(ProfileTab.about),
          ),
          ProfileTabWidget(
            label: 'Gallery',
            active: activeTab == ProfileTab.gallery,
            onTap: () => onTabChanged(ProfileTab.gallery),
          ),
          ProfileTabWidget(
            label: 'Reviews',
            active: activeTab == ProfileTab.reviews,
            onTap: () => onTabChanged(ProfileTab.reviews),
          ),
        ],
      ),
    );
  }
}
 
class ProfileTabWidget extends StatelessWidget {
  const ProfileTabWidget({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });
 
  final String label;
  final bool active;
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? DesignTokens.primary : DesignTokens.textMuted,
                ),
              ),
            ),
            if (active)
              Container(
                height: 2.5,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: DesignTokens.primary,
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusFull),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
