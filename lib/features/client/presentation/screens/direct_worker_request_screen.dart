import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/location/device_location_service.dart';
import '../../../../core/location/place_lookup_service.dart';
import '../../../../core/offline/job_post_queue.dart';
import '../../../../core/services/categories_service.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/artisan_logo_avatar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/job_location_map.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../navigation/client_navigation.dart';

class DirectWorkerRequestScreen extends StatefulWidget {
  const DirectWorkerRequestScreen({super.key, this.artisan});

  final Map<String, dynamic>? artisan;

  @override
  State<DirectWorkerRequestScreen> createState() =>
      _DirectWorkerRequestScreenState();
}

class _DirectWorkerRequestScreenState extends State<DirectWorkerRequestScreen> {
  final JobsService _jobsService = JobsService();
  final CategoriesService _categoriesService = CategoriesService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _photoUrls = <String>[];

  List<dynamic> _categories = <dynamic>[];
  List<PlaceSuggestion> _suggestions = <PlaceSuggestion>[];
  String? _categoryId;
  bool _loading = true;
  bool _submitting = false;
  bool _uploadingPhoto = false;
  String _urgency = 'asap';
  LatLng _pin = LatLng(
    DeviceLocation.accraDefault.latitude,
    DeviceLocation.accraDefault.longitude,
  );
  Timer? _searchDebounce;
  Timer? _reverseDebounce;

  Map<String, dynamic> get _artisan =>
      Map<String, dynamic>.from(widget.artisan ?? const <String, dynamic>{});

  Map<String, dynamic> get _profile => Map<String, dynamic>.from(
        _artisan['profiles'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      );

  String get _workerId =>
      (_artisan['id'] ?? _artisan['worker_id'] ?? _artisan['userId'] ?? _profile['id'] ?? '')
          .toString();

  String get _name =>
      (_artisan['name'] ?? _profile['full_name'] ?? 'Artisan').toString();

  String get _profession =>
      (_artisan['profession'] ?? 'Artisan').toString();

  String get _imageUrl =>
      (_artisan['imageUrl'] ?? _profile['avatar_url'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    _titleController.text = 'Service with $_name';
    _descriptionController.text =
        'I would like to request $_name for this service.';
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _reverseDebounce?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait<dynamic>([
        _categoriesService.listCategories(),
        DeviceLocationService.getCurrentOrDefault(),
      ]);
      final List<dynamic> categories = results[0] as List<dynamic>;
      final dynamic loc = results[1];
      final LatLng pin = LatLng(loc.latitude as double, loc.longitude as double);
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _categoryId = _guessCategory(categories);
        _pin = pin;
        _loading = false;
      });
      unawaited(_updateAddressFromPin(pin));
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.showError(context, e, fallback: 'Could not prepare request.');
    }
  }

  String? _guessCategory(List<dynamic> categories) {
    final String text = <String>[
      _profession,
      ...(_artisan['skills'] is List
          ? (_artisan['skills'] as List).map((dynamic item) => item.toString())
          : <String>[]),
    ].join(' ').toLowerCase();
    for (final dynamic item in categories) {
      final Map<String, dynamic> category = Map<String, dynamic>.from(item as Map);
      final String name = (category['name'] ?? '').toString().toLowerCase();
      final String slug = (category['slug'] ?? '').toString().toLowerCase();
      if ((name.isNotEmpty && text.contains(name)) ||
          (slug.isNotEmpty && text.contains(slug))) {
        return category['id'] as String?;
      }
    }
    return categories.isNotEmpty
        ? (categories.first as Map<String, dynamic>)['id'] as String?
        : null;
  }

  bool get _canSubmit =>
      !_submitting &&
      _workerId.isNotEmpty &&
      _categoryId != null &&
      _titleController.text.trim().length >= 3 &&
      _descriptionController.text.trim().length >= 20 &&
      _addressController.text.trim().isNotEmpty;

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      final List<PlaceSuggestion> places =
          await PlaceLookupService.instance.search(value);
      if (mounted) setState(() => _suggestions = places);
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    final result = await PlaceLookupService.instance.details(suggestion.placeId);
    if (result == null || !mounted) return;
    setState(() {
      _pin = result.position;
      _addressController.text = result.address;
      _searchController.text = suggestion.description;
      _suggestions = <PlaceSuggestion>[];
    });
  }

  void _onPinChanged(LatLng value) {
    setState(() => _pin = value);
    _reverseDebounce?.cancel();
    _reverseDebounce = Timer(
      const Duration(milliseconds: 500),
      () => _updateAddressFromPin(value),
    );
  }

  Future<void> _updateAddressFromPin(LatLng pin) async {
    final String? address = await PlaceLookupService.instance.reverseGeocode(pin);
    if (!mounted || address == null) return;
    setState(() => _addressController.text = address);
  }

  Future<void> _pickPhoto() async {
    if (_uploadingPhoto || _photoUrls.length >= 5) return;
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (file == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      final String? url = await StorageService.instance.uploadJobPhoto(File(file.path));
      if (!mounted) return;
      if (url != null) setState(() => _photoUrls.add(url));
    } catch (e) {
      if (mounted) AppToast.showError(context, e, fallback: 'Could not upload photo.');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    final String idempotencyKey = const Uuid().v4();
    final Map<String, dynamic> payload = <String, dynamic>{
      'category_id': _categoryId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'photo_urls': _photoUrls,
      'location_lat': _pin.latitude,
      'location_lng': _pin.longitude,
      'address_label': _addressController.text.trim(),
      'job_mode': _urgency,
      'budget_type': 'fixed',
      'budget_fixed': 50,
      'budget_min': 50,
      'budget_max': 50,
      'service_type': 'home_visit',
      'requested_worker_id': _workerId,
    };
    if (_urgency == 'scheduled') {
      payload['scheduled_for'] = DateTime.now()
          .add(const Duration(days: 1))
          .toUtc()
          .toIso8601String();
    }

    try {
      final dynamic created = await _jobsService.createJob(
        payload,
        idempotencyKey: idempotencyKey,
      );
      if (!mounted) return;
      final Map<String, dynamic> jobData = Map<String, dynamic>.from(created as Map);
      AppToast.showSuccess(context, 'Request sent to $_name.');
      ClientNavigation.startFindingArtisan(
        context,
        jobData: jobData,
        artisan: _artisan,
      );
    } catch (e) {
      final bool offline = e is NetworkException;
      if (offline) {
        await JobPostQueue.instance.enqueue(payload, idempotencyKey: idempotencyKey);
        if (!mounted) return;
        AppToast.showInfo(context, 'Request queued and will post when connection returns.');
        ClientNavigation.goToBookingsTab(context);
      } else if (mounted) {
        AppToast.showError(
          context,
          e,
          fallback: userMessageFor(e, fallback: 'Could not send request.'),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Request Worker',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      ArtisanLogoAvatar(imageUrl: _imageUrl, size: 56),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(_name, style: AppTypography.labelLarge),
                            Text(
                              _profession,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<String>(
                    initialValue: _categoryId,
                    decoration: const InputDecoration(labelText: 'Service category'),
                    items: _categories
                        .map((dynamic item) {
                          final Map<String, dynamic> category =
                              Map<String, dynamic>.from(item as Map);
                          return DropdownMenuItem<String>(
                            value: category['id'] as String,
                            child: Text((category['name'] ?? 'Service').toString()),
                          );
                        })
                        .toList(),
                    onChanged: (String? value) => setState(() => _categoryId = value),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Request title'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'What do you need done?'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search service location',
                      prefixIcon: Icon(PhosphorIcons.magnifyingGlass),
                    ),
                  ),
                  if (_suggestions.isNotEmpty)
                    ..._suggestions.map(
                      (PlaceSuggestion suggestion) => ListTile(
                        title: Text(suggestion.description),
                        onTap: () => _selectSuggestion(suggestion),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  JobLocationMap(
                    initial: _pin,
                    height: 180,
                    onPositionChanged: _onPinChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Address'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SegmentedButton<String>(
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(value: 'asap', label: Text('ASAP')),
                      ButtonSegment<String>(value: 'scheduled', label: Text('Scheduled')),
                    ],
                    selected: <String>{_urgency},
                    onSelectionChanged: (Set<String> value) =>
                        setState(() => _urgency = value.first),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: <Widget>[
                      Text('Photos', style: AppTypography.labelLarge),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _uploadingPhoto ? null : _pickPhoto,
                        icon: _uploadingPhoto
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(PhosphorIcons.cameraPlus),
                        label: Text('${_photoUrls.length}/5'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Send request',
                    isLoading: _submitting,
                    isEnabled: _canSubmit,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
    );
  }
}
