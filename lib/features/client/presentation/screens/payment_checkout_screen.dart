import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/core/services/payment_service.dart';
import 'package:artisans_app/shared/widgets/gradient_button.dart';
import 'package:artisans_app/shared/widgets/app_toast.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  const PaymentCheckoutScreen({
    super.key,
    required this.jobId,
    this.applicationId,
    this.initialCheckoutUrl,
    this.initialReference,
    required this.amount,
  });

  final String jobId;
  final String? applicationId;
  final String? initialCheckoutUrl;
  final String? initialReference;
  final double amount;

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> with WidgetsBindingObserver {
  final PaymentService _paymentService = PaymentService.instance;
  
  String? _checkoutUrl;
  String? _reference;
  bool _isLoading = false;
  bool _isVerifying = false;
  bool _isVerifyingSilent = false;
  bool _isCompleted = false;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkoutUrl = widget.initialCheckoutUrl;
    _reference = widget.initialReference;
    
    if (_checkoutUrl == null) {
      _initializeCheckout();
    } else {
      _launchPaymentPage();
      if (_reference != null) {
        _startPolling();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _reference != null && !_isVerifying && !_isVerifyingSilent && !_isCompleted && !_isLoading) {
      _verifyPaymentSilent();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _verifyPaymentSilent();
    });
  }

  Future<void> _verifyPaymentSilent() async {
    if (_reference == null || _isVerifying || _isVerifyingSilent || _isCompleted || !mounted) return;
    _isVerifyingSilent = true;
    try {
      final res = await _paymentService.verifyPayment(_reference!);
      final bool success = res['success'] as bool? ?? false;
      if (!mounted) return;
      if (success && !_isCompleted) {
        _isCompleted = true;
        _pollTimer?.cancel();
        AppToast.showEscrow(context, 'Payment Confirmed! Funds are securely held in Escrow.');
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      // Silent catch
    } finally {
      _isVerifyingSilent = false;
    }
  }

  Future<void> _initializeCheckout() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _paymentService.initializePayment(
        jobId: widget.jobId,
        applicationId: widget.applicationId,
        amount: widget.amount,
      );
      if (!mounted) return;
      setState(() {
        _checkoutUrl = res['checkout_url'] as String?;
        _reference = res['reference'] as String?;
        _isLoading = false;
      });
      _launchPaymentPage();
      if (_reference != null) {
        _startPolling();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to initialize payment. Please try again.';
      });
    }
  }

  Future<void> _launchPaymentPage() async {
    if (_checkoutUrl == null) return;
    try {
      final uri = Uri.parse(_checkoutUrl!);
      if (kIsWeb) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else {
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppBrowserView,
        );
        if (!launched) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not open the payment page. Please click the button below to retry.';
      });
    }
  }


  Future<void> _verifyPayment() async {
    if (_reference == null) return;
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    try {
      _pollTimer?.cancel();
      final res = await _paymentService.verifyPayment(_reference!);
      final bool success = res['success'] as bool? ?? false;
      if (!mounted) return;
      
      if (success) {
        AppToast.showEscrow(context, 'Payment Confirmed! Funds are securely held in Escrow.');
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isVerifying = false;
          _error = 'Payment verification pending. Please complete it in your browser and try again.';
        });
        _startPolling();
      }
    } catch (e) {
      if (!mounted) return;
      final String msg = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '');
      setState(() {
        _isVerifying = false;
        _error = msg.isNotEmpty ? msg : 'Verification failed. Please complete the payment first.';
      });
      _startPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete Payment'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.payments_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Escrow Booking Payment',
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Amount: GHS ${widget.amount.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'CraftMatch holds your payment securely in escrow. Workers are only paid once you approve the completed service.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 40),
              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 16),
                const Text(
                  'Preparing secure checkout gateway...',
                  textAlign: TextAlign.center,
                ),
              ] else if (_isVerifying) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 16),
                const Text(
                  'Verifying payment...',
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                if (_error != null) ...[
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                ],
                GradientButton(
                  label: 'Open Payment Page',
                  onPressed: _launchPaymentPage,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _verifyPayment,
                  child: Text(
                    'I Have Paid',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
