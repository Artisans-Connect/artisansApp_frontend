import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/shared/widgets/custom_back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 0,
    this.bottom,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
        (subtitle != null && subtitle!.isNotEmpty ? 64.0 : 56.0) +
            (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    final effectiveTitleColor = titleColor ?? AppColors.primary;

    return AppBar(
      title: subtitle != null && subtitle!.isNotEmpty
          ? Column(
              crossAxisAlignment: centerTitle
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: effectiveTitleColor,
                  ),
                ),
                Text(
                  subtitle!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: effectiveTitleColor,
              ),
            ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: elevation,
      scrolledUnderElevation: 0,
      leading: showBackButton
          ? CustomBackButton(
              color: AppColors.textPrimary,
              onPressed: onBackPressed,
            )
          : null,
      actions: actions,
      automaticallyImplyLeading: showBackButton,
      bottom: bottom,
    );
  }
}
