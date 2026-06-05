import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

const String artisanLogoAsset = 'assets/ArtisanConnect Logo - 1.png';

bool hasUsableImageUrl(String? value) {
  if (value == null) return false;
  final String trimmed = value.trim();
  return trimmed.isNotEmpty &&
      !trimmed.contains('via.placeholder.com') &&
      trimmed.toLowerCase() != 'null';
}

class ArtisanLogoAvatar extends StatelessWidget {
  const ArtisanLogoAvatar({
    super.key,
    this.imageUrl,
    this.size = 56,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final double size;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius =
        borderRadius ?? BorderRadius.circular(size / 2);
    final String? url = hasUsableImageUrl(imageUrl) ? imageUrl!.trim() : null;

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: url == null
            ? const _LogoFallback()
            : url.startsWith('http')
                ? Image.network(
                    url,
                    fit: fit,
                    errorBuilder: (_, __, ___) => const _LogoFallback(),
                  )
                : Image.file(
                    File(url),
                    fit: fit,
                    errorBuilder: (_, __, ___) => const _LogoFallback(),
                  ),
      ),
    );
  }
}

class ArtisanLogoPanel extends StatelessWidget {
  const ArtisanLogoPanel({
    super.key,
    this.imageUrl,
    required this.height,
    this.width = double.infinity,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final double height;
  final double width;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final String? url = hasUsableImageUrl(imageUrl) ? imageUrl!.trim() : null;
    final Widget child = url == null
        ? const _LogoFallback()
        : url.startsWith('http')
            ? Image.network(
                url,
                fit: fit,
                errorBuilder: (_, __, ___) => const _LogoFallback(),
              )
            : Image.file(
                File(url),
                fit: fit,
                errorBuilder: (_, __, ___) => const _LogoFallback(),
              );

    final Widget sized = SizedBox(width: width, height: height, child: child);
    if (borderRadius == null) return sized;
    return ClipRRect(borderRadius: borderRadius!, child: sized);
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryContainer,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Image.asset(
          artisanLogoAsset,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
