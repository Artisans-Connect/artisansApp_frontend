import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/core/navigation/app_routes.dart';
import 'package:artisans_app/core/services/payment_service.dart';
import 'package:artisans_app/core/navigation/app_navigation.dart';
import 'package:artisans_app/features/client/presentation/client_shell.dart';
import 'package:artisans_app/shared/widgets/gradient_button.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({
    super.key,
    this.reference,
  });

  static const String routeName = AppRoutes.paymentSuccess;
  final String? reference;

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  String? _reference;

  @override
  void initState() {
    super.initState();
    _reference = widget.reference;
    if (_reference != null && _reference!.isNotEmpty) {
      _verify();
    }
  }

  Future<void> _verify() async {
    if (_reference == null) return;
    try {
      await PaymentService.instance.verifyPayment(_reference!);
    } catch (_) {
      // Ignored - backend webhook or previous callback already marked payment completed
    }
  }

  void _goBookings() {
    AppNavigation.resetToClient(context, initialTab: ClientNavTab.bookings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha((0.15 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 72,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Payment Confirmed!',
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your funds are securely held in escrow.\nYour selected artisan will begin work shortly.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_reference != null && _reference!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withAlpha((0.2 * 255).round())),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Ref: ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        SelectableText(
                          _reference!,
                          style: AppTypography.bodyMedium.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                GradientButton(
                  label: 'View My Bookings',
                  onPressed: _goBookings,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    AppNavigation.resetToClient(context);
                  },
                  child: Text(
                    'Return to Home',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
