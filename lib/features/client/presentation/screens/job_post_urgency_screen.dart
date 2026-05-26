import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';

class JobPostUrgencyScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const JobPostUrgencyScreen({
    Key? key,
    this.jobData,
  }) : super(key: key);

  @override
  State<JobPostUrgencyScreen> createState() => _JobPostUrgencyScreenState();
}

class _JobPostUrgencyScreenState extends State<JobPostUrgencyScreen> {
  late String _budgetStyle = 'fixed';
  late String _urgency = 'asap';
  late DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  late String _selectedTimeWindow = 'Morning (8am - 12pm)';
  late double _projectBudget = 0.0;

  final List<String> timeWindows = [
    'Morning (8am - 12pm)',
    'Afternoon (12pm - 5pm)',
    'Evening (5pm - 9pm)',
    'Flexible',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.jobData != null) {
      _budgetStyle = widget.jobData!['budgetStyle'] ?? 'fixed';
      _projectBudget = widget.jobData!['projectBudget'] ?? 0.0;
      _urgency = widget.jobData!['urgency'] ?? 'asap';
    }
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP 6 OF 7',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusXLarge),
                    ),
                    child: Text(
                      '85% Complete',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                'Budget &\nUrgency',
                style: AppTypography.displayMedium,
              ),
              const SizedBox(height: AppSpacing.md),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                child: LinearProgressIndicator(
                  value: 0.85,
                  minHeight: 6,
                  backgroundColor: AppColors.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Budget Style Section
              _buildBudgetStyleSection(),
              const SizedBox(height: AppSpacing.lg),

              // Project Budget Section
              _buildProjectBudgetSection(),
              const SizedBox(height: AppSpacing.lg),

              // Urgency Section
              _buildUrgencySection(),
              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Back',
                      icon: Icons.arrow_back_ios,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: 'Review Details',
                      icon: Icons.arrow_forward_ios,
                      mainAxisAlignment: MainAxisAlignment.center,
                      onPressed: () {
                        final jobData = widget.jobData ?? {};
                        jobData['budgetStyle'] = _budgetStyle;
                        jobData['projectBudget'] = _projectBudget;
                        jobData['urgency'] = _urgency;
                        jobData['preferredDate'] = _selectedDate;
                        jobData['timeWindow'] = _selectedTimeWindow;
                        Navigator.pushNamed(
                          context,
                          AppRoutes.jobPostSummary,
                          arguments: jobData,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Promotional Card
              _buildPromotionalCard(),
              const SizedBox(height: AppSpacing.lg),

              // Quick Summary
              _buildQuickSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetStyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.wallet_outlined,
              color: AppColors.textPrimary,
              size: AppSpacing.iconMedium,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Budget Style',
              style: AppTypography.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: AppColors.outlineVariant,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: _buildBudgetStyleButton(
                  label: 'Fixed\nPrice',
                  isSelected: _budgetStyle == 'fixed',
                  onTap: () {
                    setState(() {
                      _budgetStyle = 'fixed';
                    });
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildBudgetStyleButton(
                  label: 'Price\nRange',
                  isSelected: _budgetStyle == 'range',
                  onTap: () {
                    setState(() {
                      _budgetStyle = 'range';
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetStyleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROJECT BUDGET (USD)',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatCurrency(_projectBudget),
                style: AppTypography.priceTag.copyWith(
                  fontSize: 24,
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
      ],
    );
  }

  Widget _buildUrgencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flash_on_outlined,
              color: AppColors.textPrimary,
              size: AppSpacing.iconMedium,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Urgency',
              style: AppTypography.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ASAP Option
        _buildUrgencyOption(
          icon: Icons.flash_on,
          title: 'ASAP',
          subtitle: 'Within 24 hours',
          isSelected: _urgency == 'asap',
          onTap: () {
            setState(() {
              _urgency = 'asap';
            });
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // Scheduled Option
        _buildUrgencyOption(
          icon: Icons.calendar_today,
          title: 'Scheduled',
          subtitle: 'Choose a date',
          isSelected: _urgency == 'scheduled',
          onTap: () {
            setState(() {
              _urgency = 'scheduled';
            });
          },
        ),

        if (_urgency == 'scheduled') ...[
          const SizedBox(height: AppSpacing.lg),
          _buildDateInputField(),
          const SizedBox(height: AppSpacing.md),
          _buildTimeWindowDropdown(),
        ],
      ],
    );
  }

  Widget _buildUrgencyOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
                size: AppSpacing.iconMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREFERRED DATE',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _formatDate(_selectedDate),
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeWindowDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIME WINDOW',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(
              color: AppColors.outlineVariant,
              width: 1,
            ),
          ),
          child: DropdownButton<String>(
            value: _selectedTimeWindow,
            isExpanded: true,
            underline: const SizedBox(),
            items: timeWindows.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: AppTypography.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedTimeWindow = newValue ?? _selectedTimeWindow;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionalCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1a1a3f),
            const Color(0xFF2d1b69),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Finding your perfect match',
            style: AppTypography.displaySmall.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Setting a fair budget and clear timeline helps us attract the top 1% of talent for your specific needs.',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK SUMMARY',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSummaryItem('Project Type', 'Web Development'),
        const SizedBox(height: AppSpacing.md),
        _buildSummaryItem('Scope', '3-6 Months'),
        const SizedBox(height: AppSpacing.md),
        _buildSummaryItem('Est. Total', _formatCurrency(_projectBudget)),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium,
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
