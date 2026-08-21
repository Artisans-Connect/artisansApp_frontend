import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/location/device_location_service.dart';
import 'package:artisans_app/core/location/place_lookup_service.dart';
import 'package:artisans_app/core/navigation/app_routes.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_spacing.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/shared/widgets/job_location_map.dart';
import 'package:artisans_app/features/client/presentation/models/client_job_draft.dart';
import 'package:artisans_app/features/client/presentation/models/job_post_wizard_step.dart';
import 'package:artisans_app/features/client/presentation/widgets/job_post_wizard_scaffold.dart';

/// Merged step 4: Location + Urgency/Schedule.
class JobPostLocationScheduleScreen extends StatefulWidget {
  const JobPostLocationScheduleScreen({super.key, this.jobData});

  final Map<String, dynamic>? jobData;

  @override
  State<JobPostLocationScheduleScreen> createState() =>
      _JobPostLocationScheduleScreenState();
}

class _JobPostLocationScheduleScreenState
    extends State<JobPostLocationScheduleScreen> {
  late ClientJobDraft _draft;
  late TextEditingController _addressController;
  late TextEditingController _locationSearchController;
  Timer? _searchDebounce;
  Timer? _reverseGeocodeDebounce;
  bool _showAddressEditor = false;
  bool _loadingLocation = true;
  bool _searchingPlaces = false;
  bool _reverseGeocoding = false;
  bool _usingCurrentLocation = false;
  bool _needsManualPin = false;
  List<PlaceSuggestion> _placeSuggestions = <PlaceSuggestion>[];
  LatLng _pin = LatLng(
    DeviceLocation.knustDefault.latitude,
    DeviceLocation.knustDefault.longitude,
  );

  String _urgency = 'asap';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeWindow = 'Morning (8am - 12pm)';

  static const List<String> _timeWindows = <String>[
    'Morning (8am - 12pm)',
    'Afternoon (12pm - 5pm)',
    'Evening (5pm - 9pm)',
    'Flexible',
  ];

  @override
  void initState() {
    super.initState();
    _draft = ClientJobDraft.fromMap(widget.jobData);
    _addressController = TextEditingController(
      text: _draft.address ?? '',
    );
    _locationSearchController = TextEditingController();
    _urgency = _draft.urgency ?? 'asap';
    final DateTime? date = _draft.preferredDate;
    if (date != null) _selectedDate = date;
    _selectedTimeWindow = _draft.timeWindow ?? 'Morning (8am - 12pm)';
    _initLocation();
  }

  Future<void> _initLocation() async {
    final double? existingLat = _draft.locationLat;
    final double? existingLng = _draft.locationLng;
    if (existingLat != null && existingLng != null) {
      setState(() {
        _pin = LatLng(existingLat, existingLng);
        _needsManualPin = false;
        _loadingLocation = false;
      });
      return;
    }

    final loc = await DeviceLocationService.getCurrentOrDefault();
    if (!mounted) return;

    setState(() {
      _pin = LatLng(loc.latitude, loc.longitude);
      _needsManualPin = loc.isFallback;
      _loadingLocation = false;
    });
    if (!loc.isFallback) {
      unawaited(_updateAddressFromPin(_pin));
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _reverseGeocodeDebounce?.cancel();
    _addressController.dispose();
    _locationSearchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      if (value.trim().length < 2) {
        setState(() => _placeSuggestions = <PlaceSuggestion>[]);
        return;
      }
      setState(() => _searchingPlaces = true);
      try {
        final suggestions = await PlaceLookupService.instance.search(value);
        if (!mounted) return;
        setState(() {
          _placeSuggestions = suggestions;
          _searchingPlaces = false;
        });
      } catch (_) {
        if (mounted) setState(() => _searchingPlaces = false);
      }
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    setState(() {
      _searchingPlaces = true;
      _placeSuggestions = <PlaceSuggestion>[];
      _locationSearchController.text = suggestion.description;
    });
    try {
      final result = await PlaceLookupService.instance.details(suggestion.placeId);
      if (result == null || !mounted) return;
      setState(() {
        _pin = result.position;
        _addressController.text = result.address.isNotEmpty
            ? result.address
            : suggestion.description;
        _needsManualPin = false;
        _showAddressEditor = false;
      });
    } finally {
      if (mounted) setState(() => _searchingPlaces = false);
    }
  }

  void _onPinChanged(LatLng latLng) {
    setState(() {
      _pin = latLng;
      _needsManualPin = false;
    });
    _reverseGeocodeDebounce?.cancel();
    _reverseGeocodeDebounce = Timer(
      const Duration(milliseconds: 500),
      () => _updateAddressFromPin(latLng),
    );
  }

  Future<void> _updateAddressFromPin(LatLng latLng) async {
    if (!PlaceLookupService.instance.isConfigured) return;
    setState(() => _reverseGeocoding = true);
    try {
      final String? address =
          await PlaceLookupService.instance.reverseGeocode(latLng);
      if (!mounted || address == null || address.isEmpty) return;
      setState(() => _addressController.text = address);
    } finally {
      if (mounted) setState(() => _reverseGeocoding = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    if (_usingCurrentLocation) return;
    final hasPermission =
        await DeviceLocationService.requestPermissionInteractive(context);
    if (!hasPermission) return;

    setState(() => _usingCurrentLocation = true);
    try {
      final loc = await DeviceLocationService.getCurrentOrDefault();
      if (!mounted) return;
      final LatLng pin = LatLng(loc.latitude, loc.longitude);
      setState(() {
        _pin = pin;
        _needsManualPin = loc.isFallback;
        _showAddressEditor = false;
        _placeSuggestions = <PlaceSuggestion>[];
        _locationSearchController.text = '';
      });
      if (!loc.isFallback) {
        await _updateAddressFromPin(pin);
      }
    } finally {
      if (mounted) setState(() => _usingCurrentLocation = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  bool get _canContinue =>
      _addressController.text.trim().isNotEmpty &&
      !_loadingLocation &&
      !_needsManualPin;

  void _continue() {
    _draft.merge(<String, dynamic>{
      'address': _addressController.text.trim(),
      'locationLat': _pin.latitude,
      'locationLng': _pin.longitude,
      'urgency': _urgency,
      'preferredDate': _selectedDate,
      'timeWindow': _selectedTimeWindow,
    });
    Navigator.pushNamed(
      context,
      AppRoutes.jobPostSummary,
      arguments: _draft.toMap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JobPostWizardScaffold(
      step: JobPostWizardStep.locationSchedule,
      headline: 'Location & schedule',
      primaryLabel: 'Review details',
      primaryEnabled: _canContinue,
      onPrimary: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Map ─────────────────────────────────────────────────
          Text(
            'Where should the artisan come?',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _usingCurrentLocation ? null : _useCurrentLocation,
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
            controller: _locationSearchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search for a location',
              prefixIcon: Icon(PhosphorIcons.magnifyingGlass),
              suffixIcon: _searchingPlaces
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
            ),
          ),
          if (_placeSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: _placeSuggestions
                    .map(
                      (PlaceSuggestion suggestion) => ListTile(
                        leading: Icon(
                          PhosphorIcons.mapPin,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          suggestion.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _selectSuggestion(suggestion),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          if (_loadingLocation)
            Container(
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              child: const CircularProgressIndicator(),
            )
          else
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusLarge),
              child: JobLocationMap(
                initial: _pin,
                height: 180,
                onPositionChanged: _onPinChanged,
              ),
            ),
          if (_needsManualPin) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We could not access your GPS. Move the map pin to the job location before continuing.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(PhosphorIcons.mapPin, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _showAddressEditor
                      ? 'Edit address'
                      : _addressController.text.isNotEmpty
                          ? _addressController.text
                          : 'Tap to add address',
                  style: AppTypography.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(PhosphorIcons.pencilSimple),
                onPressed: () => setState(
                    () => _showAddressEditor = !_showAddressEditor),
              ),
            ],
          ),
          if (_reverseGeocoding)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Updating address from map pin...',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          if (_showAddressEditor) ...[
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. 15 Adum Street, Kumasi',
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMedium),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],

          // ── Urgency ─────────────────────────────────────────────
          const SizedBox(height: AppSpacing.xl),
          Text('When do you need this done?',
              style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          _UrgencyTile(
            title: 'ASAP',
            subtitle: 'Within 24 hours',
            icon: PhosphorIcons.lightning,
            selected: _urgency == 'asap',
            onTap: () => setState(() => _urgency = 'asap'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _UrgencyTile(
            title: 'Scheduled',
            subtitle: 'Pick a specific date & time',
            icon: PhosphorIcons.calendarBlank,
            selected: _urgency == 'scheduled',
            onTap: () => setState(() => _urgency = 'scheduled'),
          ),

          // ── Scheduled options ───────────────────────────────────
          if (_urgency == 'scheduled') ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusLarge),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(PhosphorIcons.calendarBlank,
                        color: AppColors.primary),
                    title: const Text('Preferred date'),
                    subtitle: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    trailing: Icon(PhosphorIcons.caretRight,
                        color: AppColors.textSecondary),
                    onTap: _selectDate,
                  ),
                  const Divider(),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTimeWindow,
                    decoration: InputDecoration(
                      labelText: 'Time window',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMedium),
                      ),
                    ),
                    items: _timeWindows
                        .map(
                          (String w) => DropdownMenuItem<String>(
                            value: w,
                            child: Text(w,
                                overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) {
                      if (v != null) {
                        setState(() => _selectedTimeWindow = v);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UrgencyTile extends StatelessWidget {
  const _UrgencyTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          color: selected
              ? AppColors.primaryContainer.withValues(alpha: 0.2)
              : AppColors.surfaceContainerLowest,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelLarge),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(PhosphorIcons.checkCircle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
