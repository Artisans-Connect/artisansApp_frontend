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

class JobPostLocationScreen extends StatefulWidget {
  const JobPostLocationScreen({super.key, this.jobData});

  final Map<String, dynamic>? jobData;

  @override
  State<JobPostLocationScreen> createState() => _JobPostLocationScreenState();
}

class _JobPostLocationScreenState extends State<JobPostLocationScreen> {
  late ClientJobDraft _draft;
  late TextEditingController _addressController;
  bool _showAddressEditor = false;
  bool _loadingLocation = true;
  LatLng _pin = LatLng(
    DeviceLocation.accraDefault.latitude,
    DeviceLocation.accraDefault.longitude,
  );

  @override
  void initState() {
    super.initState();
    _draft = ClientJobDraft.fromMap(widget.jobData);
    _addressController = TextEditingController(
      text: _draft.address ?? '123 Osu St, Accra, Ghana',
    );
    _initLocation();
  }

  Future<void> _initLocation() async {
    final loc = await DeviceLocationService.getCurrentOrDefault();
    if (!mounted) return;
    setState(() {
      _pin = LatLng(loc.latitude, loc.longitude);
      _loadingLocation = false;
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _continue() {
    _draft.merge(<String, dynamic>{
      'address': _addressController.text.trim(),
      'locationLat': _pin.latitude,
      'locationLng': _pin.longitude,
    });
    Navigator.pushNamed(
      context,
      AppRoutes.jobPostUrgency,
      arguments: _draft.toMap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JobPostWizardScaffold(
      step: JobPostWizardStep.location,
      headline: 'Where is the job?',
      primaryLabel: 'Next',
      primaryEnabled: _addressController.text.trim().isNotEmpty && !_loadingLocation,
      onPrimary: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Artisans use this to estimate travel time and availability.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_loadingLocation)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          else
            JobLocationMap(
              initial: _pin,
              height: 200,
              onPositionChanged: (latLng) => setState(() => _pin = latLng),
            ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(PhosphorIcons.mapPin, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _showAddressEditor
                      ? 'Edit address'
                      : _addressController.text,
                  style: AppTypography.labelLarge,
                ),
              ),
              IconButton(
                icon: Icon(PhosphorIcons.pencilSimple),
                onPressed: () =>
                    setState(() => _showAddressEditor = !_showAddressEditor),
              ),
            ],
          ),
          if (_showAddressEditor) ...[
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ],
      ),
    );
  }
}
