import 'package:flutter/material.dart';

import '../models/picked_media.dart';

class PickedMediaImage extends StatelessWidget {
  const PickedMediaImage({
    super.key,
    required this.media,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  final PickedMedia media;
  final BoxFit fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      media.bytes,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}
