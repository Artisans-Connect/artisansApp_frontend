import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/index.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
