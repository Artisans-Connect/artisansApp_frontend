import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

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

  Future<String?> uploadAvatar(File file) async {
    return _uploadFile(file, AppConstants.avatarsBucket);
  }

  Future<String?> uploadJobPhoto(File file) async {
    return _uploadFile(file, AppConstants.jobPhotosBucket);
  }

  Future<String?> _uploadFile(File file, String bucketName) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split(Platform.pathSeparator).last}';
      await _supabase.storage.from(bucketName).upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      return _supabase.storage.from(bucketName).getPublicUrl(fileName);
    } catch (e) {
      throw StorageException(
        'Upload failed. Check your connection and try again.',
      );
    }
  }
}
