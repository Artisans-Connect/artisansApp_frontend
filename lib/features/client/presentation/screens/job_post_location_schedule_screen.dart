import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/location/device_location_service.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/job_location_map.dart';
import '../models/client_job_draft.dart';
import '../models/job_post_wizard_step.dart';
import '../widgets/job_post_wizard_scaffold.dart';

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
  bool _showAddressEditor = false;
  bool _loadingLocation = true;
  bool _needsManualPin = false;
  LatLng _pin = LatLng(
    DeviceLocation.accraDefault.latitude,
    DeviceLocation.accraDefault.longitude,
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
    _urgency = _draft.urgency ?? 'asap';
    final Object? date = _draft.data['preferredDate'];
    if (date is DateTime) _selectedDate = date;
    _selectedTimeWindow = _draft.timeWindow ?? 'Morning (8am - 12pm)';
    _initLocation();
  }

  Future<void> _initLocation() async {
    final loc = await DeviceLocationService.getCurrentOrDefault();
    if (!mounted) return;

    if (_addressController.text.isEmpty && !loc.isFallback) {
      _addressController.text =
          'Lat: ${loc.latitude.toStringAsFixed(4)}, Lng: ${loc.longitude.toStringAsFixed(4)}';
    }

    setState(() {
      _pin = LatLng(loc.latitude, loc.longitude);
      _needsManualPin = loc.isFallback;
      _loadingLocation = false;
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
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
                onPositionChanged: (latLng) =>
                    setState(() {
                      _pin = latLng;
                      _needsManualPin = false;
                    }),
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
