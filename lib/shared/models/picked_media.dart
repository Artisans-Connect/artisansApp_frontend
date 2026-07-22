import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class PickedMedia {
  const PickedMedia({
    required this.name,
    required this.path,
    required this.bytes,
  });

  final String name;
  final String path;
  final Uint8List bytes;

  static Future<PickedMedia> fromXFile(XFile file) async {
    return PickedMedia(
      name: file.name,
      path: file.path,
      bytes: await file.readAsBytes(),
    );
  }
}
