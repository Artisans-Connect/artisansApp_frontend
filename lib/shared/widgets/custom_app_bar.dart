import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'custom_back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null && subtitle!.isNotEmpty ? 64 : 56);

  @override
  Widget build(BuildContext context) {
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
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.primary,
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
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.surface,
      elevation: elevation,
      leading: showBackButton
          ? CustomBackButton(
              color: AppColors.textPrimary,
              onPressed: onBackPressed,
            )
          : null,
      actions: actions,
      automaticallyImplyLeading: showBackButton,
    );
  }
}
