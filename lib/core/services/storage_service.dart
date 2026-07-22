import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../../shared/models/picked_media.dart';

class StorageException implements Exception {
  const StorageException(this.message);
  final String message;
  @override
  String toString() => message;
}

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  final _supabase = Supabase.instance.client;

  Future<String?> uploadAvatar(PickedMedia media) async {
    return _uploadMedia(media, AppConstants.avatarsBucket);
  }

  Future<String?> uploadJobPhoto(PickedMedia media) async {
    return _uploadMedia(media, AppConstants.jobPhotosBucket);
  }

  Future<String?> uploadChatMedia(PickedMedia media) async {
    return _uploadMedia(media, AppConstants.chatMediaBucket);
  }

  Future<String?> uploadCompletionPhoto(PickedMedia media) async {
    return _uploadMedia(media, AppConstants.completionPhotosBucket);
  }

  Future<String?> _uploadMedia(PickedMedia media, String bucketName) async {
    try {
      final String userId = _supabase.auth.currentUser?.id ?? 'anonymous';
      final String originalName = media.name.isNotEmpty
          ? media.name
          : media.path.split(RegExp(r'[/\\]')).last;
      final String safeName = originalName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final String fileName =
          '$userId/${DateTime.now().millisecondsSinceEpoch}_$safeName';
      await _supabase.storage.from(bucketName).uploadBinary(
            fileName,
            media.bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: _contentTypeFor(fileName),
            ),
          );

      return _supabase.storage.from(bucketName).getPublicUrl(fileName);
    } catch (e) {
      throw StorageException(
        'Upload failed. Check your connection and try again.',
      );
    }
  }

  String _contentTypeFor(String path) {
    final String lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.webm')) return 'video/webm';
    return 'image/jpeg';
  }
}
