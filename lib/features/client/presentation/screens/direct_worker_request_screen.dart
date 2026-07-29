import 'dart:async';

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
import '../../../../core/services/pricing_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/models/picked_media.dart';
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
  final PricingService _pricingService = PricingService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _photoUrls = <String>[];

  List<Map<String, dynamic>> _workerCategories = <Map<String, dynamic>>[];
  List<PlaceSuggestion> _suggestions = <PlaceSuggestion>[];
  String? _categoryId;
  bool _usingFallbackCategories = false;
  bool _loading = true;
  bool _submitting = false;
  bool _uploadingPhoto = false;
  bool _usingCurrentLocation = false;
  bool _updatingAddress = false;
  String _urgency = 'asap';
  FeeEstimate? _estimate;
  bool _estimating = false;
  bool _estimateFailed = false;
  LatLng _pin = LatLng(
    DeviceLocation.knustDefault.latitude,
    DeviceLocation.knustDefault.longitude,
  );
  Timer? _searchDebounce;
  Timer? _reverseDebounce;
  Timer? _estimateDebounce;

  Map<String, dynamic> get _artisan =>
      Map<String, dynamic>.from(widget.artisan ?? const <String, dynamic>{});

  Map<String, dynamic> get _profile => Map<String, dynamic>.from(
        _artisan['profiles'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      );

  String get _workerId => (_artisan['id'] ??
          _artisan['worker_id'] ??
          _artisan['userId'] ??
          _profile['id'] ??
          '')
      .toString();

  String get _name =>
      (_artisan['name'] ?? _profile['full_name'] ?? 'Artisan').toString();

  String get _profession => (_artisan['profession'] ?? 'Artisan').toString();

  String get _imageUrl =>
      (_artisan['imageUrl'] ?? _profile['avatar_url'] ?? '').toString();

  bool get _isVerified {
    final dynamic worker = _artisan['worker'];
    return _artisan['is_verified'] == true ||
        _artisan['isVerified'] == true ||
        _artisan['verified'] == true ||
        (worker is Map && worker['is_verified'] == true);
  }

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
    _estimateDebounce?.cancel();
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
      final LatLng pin =
          LatLng(loc.latitude as double, loc.longitude as double);
      if (!mounted) return;
      final List<Map<String, dynamic>> workerCategories =
          _resolveWorkerCategories(categories);
      final List<Map<String, dynamic>> selectableCategories =
          workerCategories.isNotEmpty
              ? workerCategories
              : categories
                  .whereType<Map<dynamic, dynamic>>()
                  .map((Map<dynamic, dynamic> item) =>
                      Map<String, dynamic>.from(item))
                  .toList();
      setState(() {
        _workerCategories = selectableCategories;
        _usingFallbackCategories = workerCategories.isEmpty;
        _categoryId = selectableCategories.length == 1
            ? selectableCategories.first['id'] as String?
            : selectableCategories.isNotEmpty
                ? selectableCategories.first['id'] as String?
                : null;
        _pin = pin;
        _loading = false;
      });
      unawaited(_updateAddressFromPin(pin));
      _refreshEstimate();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.showError(context, e, fallback: 'Could not prepare request.');
    }
  }

  static const Map<String, List<String>> _categoryAliases = <String, List<String>>{
    'construction_building': <String>["construction", "building", "builder", "mason", "carpenter", "tiler", "painter", "welder", "steel bender", "ceiling", "glass", "roof", "paver", "masonry", "blockwork", "roofing", "woodwork", "metal", "fabricator"],
    'electrical_power': <String>["electrical", "electrician", "wiring", "lighting", "socket", "outlet", "generator", "inverter", "solar", "battery", "cctv", "security", "intercom", "power", "appliance"],
    'plumbing_water': <String>["plumbing", "plumber", "pipe", "pipes", "leak", "borehole", "pump", "drainage", "sanitary", "sink", "toilet", "shower", "water"],
    'auto_mechanical': <String>["auto", "mechanic", "car", "vehicle", "vulcanizer", "sprayer", "motorcycle", "heavy equipment", "excavator", "truck", "tyre", "wheel", "engine"],
    'home_repairs': <String>["home", "repairs", "handyman", "furniture", "door", "window", "pest", "cleaner", "gardener", "lock", "hinge", "fumigation", "cleaning", "maintenance"],
    'beauty_fashion': <String>["beauty", "fashion", "hairdresser", "barber", "makeup", "tailor", "dressmaker", "shoemaker", "cobbler", "bead", "milliner", "hair", "wig", "uniform", "sandal", "jeweller"],
    'electronics_it': <String>["electronics", "phones", "it", "phone", "laptop", "tv", "sound", "printer", "computer", "desktop", "screen", "keyboard", "copier"],
    'hospitality_events': <String>["hospitality", "events", "caterer", "baker", "decorator", "photographer", "videographer", "dj", "canopy", "chair", "food", "cake", "balloon", "tent", "music"],
    'arts_crafts': <String>["arts", "craft", "potter", "weaver", "wood carver", "drum", "goldsmith", "jeweller", "brass smith", "signwriter", "clay", "pot", "kente", "basket", "carving", "sticker", "signboard"],
  };

  List<Map<String, dynamic>> _resolveWorkerCategories(
      List<dynamic> categories) {
    final List<String> workerTerms = <String>[
      _profession.toLowerCase(),
      ...(_artisan['skills'] is List
          ? (_artisan['skills'] as List).map((dynamic item) => item.toString().toLowerCase())
          : <String>[]),
    ];

    final List<Map<String, dynamic>> matches = <Map<String, dynamic>>[];
    for (final dynamic item in categories) {
      final Map<String, dynamic> category =
          Map<String, dynamic>.from(item as Map);
      final String name = (category['name'] ?? '').toString().toLowerCase();
      final String slug = (category['slug'] ?? '').toString().toLowerCase();

      bool isMatch = workerTerms.any((term) =>
          name.contains(term) ||
          term.contains(name) ||
          slug.contains(term) ||
          term.contains(slug));

      if (!isMatch) {
        final List<String> aliases = _categoryAliases[slug] ?? <String>[];
        isMatch = workerTerms.any((term) =>
            aliases.any((alias) => term.contains(alias) || alias.contains(term)));
      }

      if (isMatch) {
        matches.add(category);
      }
    }
    return matches;
  }

  bool get _canSubmit =>
      !_submitting &&
      _workerId.isNotEmpty &&
      _categoryId != null &&
      _titleController.text.trim().length >= 3 &&
      _descriptionController.text.trim().length >= 20 &&
      _addressController.text.trim().isNotEmpty;

  /// Fetches the real fee estimate for the selected category/location/mode
  /// (debounced). The estimate replaces the old hardcoded GH₵50 budget.
  void _refreshEstimate() {
    final String? categoryId = _categoryId;
    if (categoryId == null) return;
    _estimateDebounce?.cancel();
    _estimateDebounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() {
        _estimating = true;
        _estimateFailed = false;
      });
      try {
        final FeeEstimate estimate = await _pricingService.estimateFee(
          categoryId: categoryId,
          locationLat: _pin.latitude,
          locationLng: _pin.longitude,
          jobMode: _urgency,
        );
        if (!mounted) return;
        setState(() {
          _estimate = estimate;
          _estimating = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _estimating = false;
          _estimateFailed = true;
        });
      }
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      final List<PlaceSuggestion> places =
          await PlaceLookupService.instance.search(value);
      if (mounted) setState(() => _suggestions = places);
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    final result =
        await PlaceLookupService.instance.details(suggestion.placeId);
    if (result == null || !mounted) return;
    setState(() {
      _pin = result.position;
      _addressController.text = result.address;
      _searchController.text = suggestion.description;
      _suggestions = <PlaceSuggestion>[];
    });
    _refreshEstimate();
  }

  void _onPinChanged(LatLng value) {
    setState(() => _pin = value);
    _reverseDebounce?.cancel();
    _reverseDebounce = Timer(
      const Duration(milliseconds: 500),
      () => _updateAddressFromPin(value),
    );
    _refreshEstimate();
  }

  Future<void> _updateAddressFromPin(LatLng pin) async {
    if (mounted) setState(() => _updatingAddress = true);
    final String? address =
        await PlaceLookupService.instance.reverseGeocode(pin);
    if (!mounted) return;
    setState(() {
      if (address != null) _addressController.text = address;
      _updatingAddress = false;
    });
  }

  Future<void> _useCurrentLocation() async {
    if (_usingCurrentLocation) return;
    final hasPermission =
        await DeviceLocationService.requestPermissionInteractive(context);
    if (!hasPermission) return;

    setState(() => _usingCurrentLocation = true);
    try {
      final DeviceLocation loc =
          await DeviceLocationService.getCurrentOrDefault();
      final LatLng pin = LatLng(loc.latitude, loc.longitude);
      if (!mounted) return;
      setState(() {
        _pin = pin;
        _suggestions = <PlaceSuggestion>[];
        _searchController.text = '';
      });
      _refreshEstimate();
      if (loc.isFallback) {
        AppToast.showInfo(
          context,
          'Location permission is unavailable. Search or move the pin to set the job address.',
        );
      }
      await _updateAddressFromPin(pin);
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, e,
            fallback: 'Could not use current location.');
      }
    } finally {
      if (mounted) setState(() => _usingCurrentLocation = false);
    }
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
      final PickedMedia media = await PickedMedia.fromXFile(file);
      final String? url =
          await StorageService.instance.uploadJobPhoto(media);
      if (!mounted) return;
      if (url != null) setState(() => _photoUrls.add(url));
    } catch (e) {
      if (mounted)
        AppToast.showError(context, e, fallback: 'Could not upload photo.');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    final String idempotencyKey = const Uuid().v4();
    // Real estimated budget; falls back to the server-side minimum (GH₵50)
    // only when the pricing API was unreachable.
    final int budget = _estimate != null ? _estimate!.minimumFee.round() : 50;
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
      'budget_fixed': budget,
      'budget_min': budget,
      'budget_max': budget,
      'service_type': 'home_visit',
      'requested_worker_id': _workerId,
    };
    if (_urgency == 'scheduled') {
      payload['scheduled_for'] =
          DateTime.now().add(const Duration(days: 1)).toUtc().toIso8601String();
    }

    try {
      await _jobsService.createJob(
        payload,
        idempotencyKey: idempotencyKey,
      );
      if (!mounted) return;
      AppToast.showSuccess(context, 'Request sent to $_name.');
      ClientNavigation.goToBookingsTab(context);
    } catch (e) {
      final bool offline = e is NetworkException;
      if (offline) {
        await JobPostQueue.instance
            .enqueue(payload, idempotencyKey: idempotencyKey);
        if (!mounted) return;
        AppToast.showInfo(
            context, 'Request queued and will post when connection returns.');
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.gutter,
                AppSpacing.gutter,
                120,
              ),
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
                  if (!_isVerified) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    _buildUnverifiedNotice(),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _buildWorkerServiceSelector(),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _titleController,
                    decoration:
                        const InputDecoration(labelText: 'Request title'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: 'What do you need done?'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton.icon(
                    onPressed:
                        _usingCurrentLocation ? null : _useCurrentLocation,
                    icon: _usingCurrentLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(PhosphorIcons.crosshair),
                    label: const Text('Use my current location'),
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                  if (_updatingAddress)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Updating address...',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Address fallback',
                      helperText:
                          'Edit only if the map address is not precise.',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SegmentedButton<String>(
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(value: 'asap', label: Text('ASAP')),
                      ButtonSegment<String>(
                          value: 'scheduled', label: Text('Scheduled')),
                    ],
                    selected: <String>{_urgency},
                    onSelectionChanged: (Set<String> value) {
                      setState(() => _urgency = value.first);
                      _refreshEstimate();
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildEstimateCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPhotoPicker(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
      bottomNavigationBar: _loading
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.sm,
                  AppSpacing.gutter,
                  AppSpacing.gutter,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
                child: PrimaryButton(
                  label: 'Send request',
                  isLoading: _submitting,
                  isEnabled: _canSubmit,
                  onPressed: _submit,
                ),
              ),
            ),
    );
  }

  Widget _buildWorkerServiceSelector() {
    if (_workerCategories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        child: Text(
          'This worker profile needs service setup before direct requests can be sent.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.error,
          ),
        ),
      );
    }

    if (_workerCategories.length == 1) {
      final Map<String, dynamic> category = _workerCategories.first;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_usingFallbackCategories) ...<Widget>[
            _buildServiceFallbackNotice(),
            const SizedBox(height: AppSpacing.sm),
          ],
          InputDecorator(
            decoration: InputDecoration(
              labelText:
                  _usingFallbackCategories ? 'Service category' : 'Worker service',
            ),
            child: Text((category['name'] ?? 'Service').toString()),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (_usingFallbackCategories) ...<Widget>[
          _buildServiceFallbackNotice(),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(
          _usingFallbackCategories ? 'Service category' : 'Worker service',
          style: AppTypography.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _workerCategories.map((Map<String, dynamic> category) {
            final String id = (category['id'] ?? '').toString();
            final bool selected = _categoryId == id;
            return FilterChip(
              label: Text((category['name'] ?? 'Service').toString()),
              selected: selected,
              onSelected: (_) {
                setState(() => _categoryId = id);
                _refreshEstimate();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEstimateCard() {
    final FeeEstimate? estimate = _estimate;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Icon(PhosphorIcons.currencyCircleDollar,
              color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _estimating
                ? Row(
                    children: <Widget>[
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Calculating estimate...',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : estimate != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Estimated minimum: ${estimate.formatGhs(estimate.minimumFee)}',
                            style: AppTypography.labelLarge,
                          ),
                          Text(
                            'Final price is confirmed by the artisan\'s quote.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _estimateFailed
                            ? 'Could not load a fee estimate. A minimum budget will be used.'
                            : 'Select a service to see the fee estimate.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnverifiedNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(PhosphorIcons.warningCircle, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'This worker has not been verified yet. You can still send the request.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceFallbackNotice() {
    return Text(
      'This worker has not set up a service category yet. Choose the closest category for your request.',
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('Photos', style: AppTypography.labelLarge),
            const Spacer(),
            Text(
              'Optional',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 88,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              ..._photoUrls.map((String url) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMedium),
                          child: Image.network(
                            url,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: IconButton.filledTonal(
                            visualDensity: VisualDensity.compact,
                            iconSize: 16,
                            onPressed: () =>
                                setState(() => _photoUrls.remove(url)),
                            icon: Icon(PhosphorIcons.x),
                          ),
                        ),
                      ],
                    ),
                  )),
              if (_photoUrls.length < 5)
                OutlinedButton(
                  onPressed: _uploadingPhoto ? null : _pickPhoto,
                  style: OutlinedButton.styleFrom(
                    fixedSize: const Size(88, 88),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                  ),
                  child: _uploadingPhoto
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(PhosphorIcons.cameraPlus),
                            const SizedBox(height: 4),
                            Text('${_photoUrls.length}/5'),
                          ],
                        ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
