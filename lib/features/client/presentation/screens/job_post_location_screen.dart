import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';

class JobPostLocationScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const JobPostLocationScreen({
    Key? key,
    this.jobData,
  }) : super(key: key);

  @override
  State<JobPostLocationScreen> createState() => _JobPostLocationScreenState();
}

class _JobPostLocationScreenState extends State<JobPostLocationScreen> {
  String _selectedAddress = '123 Osu St, Accra, Ghana';
  double _mapZoom = 15.0;
  bool _showAddressEditor = false;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: widget.jobData?['address'] ?? _selectedAddress,
    );
    _selectedAddress = _addressController.text;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'ConnectFlow',
        onBackPressed: () => Navigator.pop(context),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Job Location',
                    style: AppTypography.displayMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Progress Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STEP 5 OF 7',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Progress Bar
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSmall),
                    child: LinearProgressIndicator(
                      value: 0.71,
                      minHeight: 6,
                      backgroundColor: AppColors.outlineVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Map View
            _buildMapView(),
            const SizedBox(height: AppSpacing.lg),

            // Address Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAddressCard(),
                  const SizedBox(height: AppSpacing.xl),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Back',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: PrimaryButton(
                          label: 'Next',
                          icon: Icons.arrow_forward_ios,
                          mainAxisAlignment: MainAxisAlignment.center,
                          onPressed: () {
                            final jobData = widget.jobData ?? {};
                            jobData['address'] = _selectedAddress;
                            Navigator.pushNamed(
                              context,
                              AppRoutes.jobPostUrgency,
                              arguments: jobData,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Map background
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a2e),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.handyman,
                    color: Colors.purple.withOpacity(0.5),
                    size: 64,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Artisans',
                    style: AppTypography.displayMedium.copyWith(
                      color: Colors.purple.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'ELITE CRAFTSMANSHIP ON DEMAND',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Location marker
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(
                Icons.location_on,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          // Zoom controls
          Positioned(
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            child: Column(
              children: [
                _buildZoomButton(
                  icon: Icons.add,
                  onPressed: () {
                    setState(() {
                      _mapZoom = (_mapZoom + 1).clamp(1.0, 20.0);
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildZoomButton(
                  icon: Icons.remove,
                  onPressed: () {
                    setState(() {
                      _mapZoom = (_mapZoom - 1).clamp(1.0, 20.0);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: AppSpacing.iconMedium,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SERVICE ADDRESS',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _selectedAddress,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: AppColors.primary,
                  size: AppSpacing.iconMedium,
                ),
                onPressed: () {
                  setState(() {
                    _showAddressEditor = !_showAddressEditor;
                  });
                },
              ),
            ],
          ),
          if (_showAddressEditor) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                border: Border.all(
                  color: AppColors.outlineVariant,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _addressController,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  hintText: 'Enter address...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedAddress = value;
                  });
                },
                onSubmitted: (value) {
                  setState(() {
                    _showAddressEditor = false;
                    _selectedAddress = value;
                  });
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAddressEditor = false;
                      _addressController.text = _selectedAddress;
                    });
                  },
                  child: Text(
                    'Cancel',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAddressEditor = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
