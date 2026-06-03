import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/client_job_draft.dart';
import '../models/job_post_wizard_step.dart';
import '../widgets/job_post_wizard_scaffold.dart';

class JobPostUrgencyScreen extends StatefulWidget {
  const JobPostUrgencyScreen({super.key, this.jobData});

  final Map<String, dynamic>? jobData;

  @override
  State<JobPostUrgencyScreen> createState() => _JobPostUrgencyScreenState();
}

class _JobPostUrgencyScreenState extends State<JobPostUrgencyScreen> {
  late ClientJobDraft _draft;
  String _budgetStyle = 'fixed';
  String _urgency = 'asap';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeWindow = 'Morning (8am - 12pm)';
  double _projectBudget = 200;

  static const double _minBudget = 50;
  static const double _maxBudget = 5000;

  final List<String> _timeWindows = <String>[
    'Morning (8am - 12pm)',
    'Afternoon (12pm - 5pm)',
    'Evening (5pm - 9pm)',
    'Flexible',
  ];

  @override
  void initState() {
    super.initState();
    _draft = ClientJobDraft.fromMap(widget.jobData);
    _budgetStyle = _draft.data['budgetStyle'] as String? ?? 'fixed';
    _urgency = _draft.urgency ?? 'asap';
    final num? budget = _draft.data['projectBudget'] as num?;
    if (budget != null && budget >= _minBudget) {
      _projectBudget = budget.toDouble();
    }
    final Object? date = _draft.data['preferredDate'];
    if (date is DateTime) _selectedDate = date;
    _selectedTimeWindow =
        _draft.timeWindow ?? 'Morning (8am - 12pm)';
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

  void _continue() {
    _draft.merge(<String, dynamic>{
      'budgetStyle': _budgetStyle,
      'projectBudget': _projectBudget,
      'budgetMin': _budgetStyle == 'range' ? _projectBudget * 0.8 : _projectBudget,
      'budgetMax': _projectBudget,
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
      step: JobPostWizardStep.urgency,
      headline: 'Budget & schedule',
      primaryLabel: 'Review details',
      primaryEnabled: _projectBudget >= _minBudget,
      onPrimary: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set a fair budget in Ghana cedis (GHS). Minimum GH₵${_minBudget.toInt()}.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Budget style', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _StyleChip(
                  label: 'Fixed price',
                  selected: _budgetStyle == 'fixed',
                  onTap: () => setState(() => _budgetStyle = 'fixed'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StyleChip(
                  label: 'Price range',
                  selected: _budgetStyle == 'range',
                  onTap: () => setState(() => _budgetStyle = 'range'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'PROJECT BUDGET (GHS)',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ClientJobDraft.formatGhs(_projectBudget),
            style: AppTypography.displaySmall.copyWith(color: AppColors.primary),
          ),
          Slider(
            value: _projectBudget.clamp(_minBudget, _maxBudget),
            min: _minBudget,
            max: _maxBudget,
            divisions: 99,
            label: ClientJobDraft.formatGhs(_projectBudget),
            onChanged: (double v) => setState(() => _projectBudget = v),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Urgency', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          _UrgencyTile(
            title: 'ASAP',
            subtitle: 'Within 24 hours',
            selected: _urgency == 'asap',
            onTap: () => setState(() => _urgency = 'asap'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _UrgencyTile(
            title: 'Scheduled',
            subtitle: 'Pick a date',
            selected: _urgency == 'scheduled',
            onTap: () => setState(() => _urgency = 'scheduled'),
          ),
          if (_urgency == 'scheduled') ...[
            const SizedBox(height: AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Preferred date'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: Icon(PhosphorIcons.calendarBlank),
              onTap: _selectDate,
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedTimeWindow,
              decoration: InputDecoration(
                labelText: 'Time window',
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
              ),
              items: _timeWindows
                  .map(
                    (String w) => DropdownMenuItem<String>(
                      value: w,
                      child: Text(w, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (String? v) {
                if (v != null) setState(() => _selectedTimeWindow = v);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.labelMedium.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _UrgencyTile extends StatelessWidget {
  const _UrgencyTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
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
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? PhosphorIcons.radioButton : PhosphorIcons.circle,
              color: AppColors.primary,
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
          ],
        ),
      ),
    );
  }
}
