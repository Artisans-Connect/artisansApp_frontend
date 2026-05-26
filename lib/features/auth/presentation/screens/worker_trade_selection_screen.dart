import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../models/onboarding_session.dart';
import '../../widgets/worker_onboarding_header.dart';
import 'worker_service_areas_screen.dart';

class WorkerTradeSelectionScreen extends StatefulWidget {
  const WorkerTradeSelectionScreen({super.key});

  static const String routeName = '/auth/worker/trade-selection';

  @override
  State<WorkerTradeSelectionScreen> createState() =>
      _WorkerTradeSelectionScreenState();
}

class _WorkerTradeSelectionScreenState extends State<WorkerTradeSelectionScreen> {
  final OnboardingSession _session = OnboardingSession.instance;

  static const List<String> _trades = <String>[
    'Electrician',
    'Plumber',
    'Carpenter',
    'Mason',
    'Painter',
    'Welder',
    'Appliance Repair',
    'Other',
  ];

  void _toggleTrade(String trade) {
    setState(() {
      if (_session.selectedTrades.contains(trade)) {
        _session.selectedTrades.remove(trade);
      } else {
        _session.selectedTrades.add(trade);
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
              stepLabel: 'STEP 1 OF 3',
              progress: 0.33,
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'What work do you do?',
                      style: AppTextStyles.displayMd.copyWith(fontSize: 36),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Select all that apply to help us find the right jobs for you.',
                      style: AppTextStyles.bodyLg,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _trades.map((String trade) {
                        final bool selected = _session.selectedTrades.contains(trade);
                        return FilterChip(
                          label: Text(trade),
                          selected: selected,
                          onSelected: (_) => _toggleTrade(trade),
                          selectedColor: AppColors.primary.withOpacity(0.12),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: selected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: selected ? AppColors.primary : AppColors.outline,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: <Widget>[
                  GradientButton(
                    label: 'Continue',
                    trailingIcon: Icons.chevron_right,
                    onPressed: _session.selectedTrades.isEmpty
                        ? null
                        : () => Navigator.pushNamed(
                              context,
                              WorkerServiceAreasScreen.routeName,
                            ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You can change this later in Profile',
                    style: AppTextStyles.bodyMd,
                    textAlign: TextAlign.center,
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
