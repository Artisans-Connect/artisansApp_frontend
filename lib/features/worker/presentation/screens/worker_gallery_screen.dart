import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:artisans_app/core/services/profile_service.dart';
import 'package:artisans_app/core/services/storage_service.dart';
import 'package:artisans_app/core/utils/current_user.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/shared/widgets/custom_back_button.dart';
import 'package:artisans_app/shared/widgets/app_toast.dart';
import 'package:artisans_app/shared/models/picked_media.dart';

class WorkerGalleryScreen extends StatefulWidget {
  const WorkerGalleryScreen({super.key});

  @override
  State<WorkerGalleryScreen> createState() => _WorkerGalleryScreenState();
}

class _WorkerGalleryScreenState extends State<WorkerGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  bool _isUploadingPhoto = false;
  String? _error;
  List<String> _galleryUrls = [];
  final Map<String, bool> _deletingPhotos = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _fetchGallery();
  }

  Future<void> _fetchGallery() async {
    final String? uid = CurrentUser.id;
    if (uid == null || uid.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'User not authenticated.';
      });
      return;
    }

    try {
      final Map<String, dynamic> freshProfile =
          await ProfileService.instance.getProfileById(uid);
      
      final dynamic rawImages = freshProfile['job_images'] ?? [];
      final List<String> urls = [];
      if (rawImages is List) {
        for (final dynamic img in rawImages) {
          if (img.toString().isNotEmpty) {
            urls.add(img.toString());
          }
        }
      }

      if (mounted) {
        setState(() {
          _galleryUrls = urls;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load gallery.';
        });
      }
    }
  }

  Future<void> _addPhoto() async {
    if (_isUploadingPhoto) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final PickedMedia media = await PickedMedia.fromXFile(image);
      final String? url =
          await StorageService.instance.uploadCompletionPhoto(media);
      if (url != null) {
        await ProfileService.instance.addGalleryPhoto(url);
        await _fetchGallery();
        if (mounted) {
          AppToast.showSuccess(context, 'Photo added to your gallery!');
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not upload photo.');
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _deletePhoto(String url) async {
    setState(() => _deletingPhotos[url] = true);
    try {
      await ProfileService.instance.deleteGalleryPhoto(url);
      await _fetchGallery();
      if (mounted) {
        AppToast.showSuccess(context, 'Photo deleted from gallery.');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e, fallback: 'Could not delete photo.');
      }
    } finally {
      if (mounted) setState(() => _deletingPhotos.remove(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? const CustomBackButton()
            : null,
        title: Text(
          'Manage Gallery',
          style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: AppTypography.bodyMedium),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _isLoading = true);
                            _fetchGallery();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchGallery,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Upload portfolio photos or manage job completion images visible to clients.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _galleryUrls.length + 1,
                          itemBuilder: (BuildContext context, int i) {
                            if (i == _galleryUrls.length) {
                              return GestureDetector(
                                onTap: _isUploadingPhoto ? null : _addPhoto,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.borderSubtle),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      if (_isUploadingPhoto)
                                        const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                          ),
                                        )
                                      else ...[
                                        const Icon(PhosphorIcons.plus, color: AppColors.primary, size: 28),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Add Photo',
                                          style: AppTypography.labelCaps.copyWith(
                                            color: AppColors.primary,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }

                            final String url = _galleryUrls[i];
                            final bool isDeleting = _deletingPhotos[url] == true;

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.surfaceDim,
                                      child: const Icon(
                                        PhosphorIcons.image,
                                        color: AppColors.textSecondary,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  if (isDeleting)
                                    Container(
                                      color: Colors.black45,
                                      alignment: Alignment.center,
                                      child: const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    )
                                  else
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: GestureDetector(
                                        onTap: () => _deletePhoto(url),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            PhosphorIcons.trash,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
