import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';

class JobPostUrgencyScreen extends StatefulWidget {
  const JobPostUrgencyScreen({Key? key, required jobData}) : super(key: key);

  @override
  State<JobPostUrgencyScreen> createState() => _JobPostUrgencyScreenState();
}

class _JobPostUrgencyScreenState extends State<JobPostUrgencyScreen> {
  String _budgetStyle = 'fixed'; // 'fixed' or 'range'
  String _urgency = 'asap'; // 'asap' or 'scheduled'
  String _timeWindow = 'Morning (8am - 12pm)';
  late TextEditingController _budgetController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.primary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ConnectFlow',
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Section
              Text(
                'STEP 6 OF 7',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.05,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Title and Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget &\nUrgency',
                    style: AppTypography.displayLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                    ),
                  ),
                  Text(
                    '85%\nComplete',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: 0.85,
                minHeight: 6,
                backgroundColor: AppColors.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Budget Style Section
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          'Budget Style',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Budget Style Toggle
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _budgetStyle = 'fixed';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              decoration: BoxDecoration(
                                color: _budgetStyle == 'fixed'
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _budgetStyle == 'fixed'
                                      ? AppColors.primary
                                      : AppColors.outlineVariant,
                                  width: _budgetStyle == 'fixed' ? 2 : 0.5,
                                ),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Fixed',
                                      style: AppTypography.labelMedium.copyWith(
                                        color: _budgetStyle == 'fixed'
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Price',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: _budgetStyle == 'fixed'
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _budgetStyle = 'range';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              decoration: BoxDecoration(
                                color: _budgetStyle == 'range'
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _budgetStyle == 'range'
                                      ? AppColors.primary
                                      : AppColors.outlineVariant,
                                  width: _budgetStyle == 'range' ? 2 : 0.5,
                                ),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Price',
                                      style: AppTypography.labelMedium.copyWith(
                                        color: _budgetStyle == 'range'
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Range',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: _budgetStyle == 'range'
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Budget Input
                    Text(
                      'PROJECT BUDGET (USD)',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _budgetController,
                      style: AppTypography.displaySmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '\$ 0.00',
                        hintStyle: AppTypography.displaySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Average for similar projects: \$450 - \$800',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Urgency Section
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flash_on, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          'Urgency',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ASAP Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _urgency = 'asap';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: _urgency == 'asap'
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: _urgency == 'asap'
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                            width: _urgency == 'asap' ? 2 : 0.5,
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flash_on_sharp,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ASAP',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Within 24 hours',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Scheduled Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _urgency = 'scheduled';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: _urgency == 'scheduled'
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: _urgency == 'scheduled'
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                            width: _urgency == 'scheduled' ? 2 : 0.5,
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.textSecondary,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scheduled',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Choose a date',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    if (_urgency == 'scheduled') ...[
                      // Preferred Date
                      Text(
                        'PREFERRED DATE',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _dateController,
                        style: AppTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'mm/dd/yyyy',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: Icon(Icons.calendar_today, color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.all(AppSpacing.md),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                            borderSide: BorderSide(
                              color: AppColors.outlineVariant,
                              width: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Time Window
                      Text(
                        'TIME WINDOW',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(
                            color: AppColors.outlineVariant,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.schedule, color: AppColors.textSecondary),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                _timeWindow,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Icon(Icons.expand_more, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back, color: AppColors.textPrimary),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Back',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.jobPostSummary);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Review\nDetails',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Info Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Finding your perfect match',
                      style: AppTypography.displaySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Setting a fair budget and clear timeline helps us attract the top 1% of talent for your specific needs.',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quick Summary
              Text(
                'QUICK SUMMARY',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.05,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSummaryRow('Project Type', 'Web Development'),
              const SizedBox(height: AppSpacing.md),
              _buildSummaryRow('Scope', '3-6 Months'),
              const SizedBox(height: AppSpacing.md),
              _buildSummaryRow('Est. Total', '\$500.00', isHighlight: true),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore, color: AppColors.textSecondary),
            label: 'EXPLORE',
            activeIcon: Icon(Icons.explore, color: AppColors.primary),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, color: AppColors.textSecondary),
            label: 'BOOKINGS',
            activeIcon: Icon(Icons.calendar_today, color: AppColors.primary),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: AppColors.textSecondary),
            label: 'PROFILE',
            activeIcon: Icon(Icons.person, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
