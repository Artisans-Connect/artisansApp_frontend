import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

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
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final String path = await _supabase.storage.from(bucketName).upload(
        fileName,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      
      // Get the public URL
      final String publicUrl = _supabase.storage.from(bucketName).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Error uploading file to $bucketName: $e');
      return null;
    }
  }
}
