import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../models/onboarding_session.dart';
import 'complete_profile_step1_screen.dart';
import '../../widgets/worker_onboarding_header.dart';

class WorkerServiceAreasScreen extends StatefulWidget {
  const WorkerServiceAreasScreen({super.key});

  static const String routeName = '/auth/worker/service-areas';

  @override
  State<WorkerServiceAreasScreen> createState() =>
      _WorkerServiceAreasScreenState();
}

class _WorkerServiceAreasScreenState extends State<WorkerServiceAreasScreen> {
  final OnboardingSession _session = OnboardingSession.instance;

  static const List<String> _areas = <String>[
    'Adum',
    'Asokwa',
    'Bantama',
    'Suame',
    'Tafo',
    'Ahodwo',
    'Santasi',
    'KNUST',
  ];

  static const List<String> _experienceBands = <String>[
    '0–1 years',
    '1–3 years',
    '3–5 years',
    '5+ years',
  ];

  void _toggleArea(String area) {
    setState(() {
      if (_session.serviceAreas.contains(area)) {
        _session.serviceAreas.remove(area);
      } else {
        _session.serviceAreas.add(area);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F8),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            WorkerOnboardingHeader(
              stepLabel: 'STEP 2 OF 3',
              progress: 0.66,
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Where do you work?',
                      style: AppTextStyles.displayMd.copyWith(fontSize: 36),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Choose neighborhoods you can reach for jobs.',
                      style: AppTextStyles.bodyLg,
                    ),
                    const SizedBox(height: 20),
                    Text('Service areas',
                        style: AppTextStyles.bodyLg
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _areas.map((String area) {
                        final bool selected = _session.serviceAreas.contains(area);
                        return FilterChip(
                          label: Text(area),
                          selected: selected,
                          onSelected: (_) => _toggleArea(area),
                          selectedColor: AppColors.primary.withOpacity(0.12),
                          checkmarkColor: AppColors.primary,
                          side: BorderSide(
                            color: selected ? AppColors.primary : AppColors.outline,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    Text('Experience',
                        style: AppTextStyles.bodyLg
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ..._experienceBands.map((String band) {
                      final bool selected = _session.experienceBand == band;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => setState(() => _session.experienceBand = band),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.outline,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    band,
                                    style: AppTextStyles.bodyLg.copyWith(
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(Icons.check_circle,
                                      color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.info_outline,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Hourly rates are set per job after you accept a request.',
                              style: AppTextStyles.bodyMd,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: GradientButton(
                label: 'Continue',
                trailingIcon: Icons.chevron_right,
                onPressed: _session.serviceAreas.isEmpty ||
                        _session.experienceBand == null
                    ? null
                    : () => Navigator.pushNamed(
                          context,
                          CompleteProfileStep1Screen.routeName,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
