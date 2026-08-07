import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../shared/presentation/screens/user_profile_screen.dart';
import '../state/worker_session_state.dart';
import '../../../../shared/widgets/custom_back_button.dart';
import '../../../../core/services/workers_service.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../shared/widgets/app_toast.dart';

class WorkerEarningsScreen extends StatefulWidget {
  const WorkerEarningsScreen({super.key});

  @override
  State<WorkerEarningsScreen> createState() => _WorkerEarningsScreenState();
}

class _WorkerEarningsScreenState extends State<WorkerEarningsScreen> {
  final WorkersService _workersService = WorkersService();
  final PaymentService _paymentService = PaymentService.instance;
  
  bool _isLoading = true;
  String? _error;
  double _totalEarned = 0.0;
  List<dynamic> _history = [];
  Map<String, dynamic>? _payoutDetails;

  @override
  void initState() {
    super.initState();
    _fetchEarnings();
  }

  Future<void> _fetchEarnings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _workersService.getEarnings();
      final payout = await _paymentService.getPayoutDetails();
      if (mounted) {
        setState(() {
          _totalEarned = (res['total_earned'] as num?)?.toDouble() ?? 0.0;
          _history = res['history'] as List<dynamic>? ?? [];
          _payoutDetails = payout;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load earnings. Please try again.';
        });
      }
    }
  }

  void _showPayoutSetupSheet() {
    final String initialNetwork = _payoutDetails?['network'] as String? ?? 'MTN';
    final accountController = TextEditingController(text: _payoutDetails?['account_number'] as String? ?? '');
    final nameController = TextEditingController(text: _payoutDetails?['account_name'] as String? ?? '');
    String selectedNetwork = initialNetwork;
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetCtx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Setup Payout Account',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your Mobile Money details to receive automated payouts after jobs are completed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  const Text('Network Provider', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedNetwork,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'MTN', child: Text('MTN Mobile Money')),
                      DropdownMenuItem(value: 'Vodafone', child: Text('Telecel Cash (Vodafone)')),
                      DropdownMenuItem(value: 'AirtelTigo', child: Text('AirtelTigo Money')),
                    ],
                    onChanged: (String? val) {
                      if (val != null) {
                        setSheetState(() => selectedNetwork = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Mobile Money Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: accountController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'e.g. 0244123456',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Account Holder Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g. John Doe',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final net = selectedNetwork;
                      final num = accountController.text.trim();
                      final name = nameController.text.trim();
                      
                      if (num.isEmpty || name.isEmpty) {
                        AppToast.showError(context, Exception('Please fill in all fields.'));
                        return;
                      }
                      
                      Navigator.pop(sheetCtx);
                      
                      setState(() => _isLoading = true);
                      try {
                        await _paymentService.savePayoutDetails(
                          network: net,
                          accountNumber: num,
                          accountName: name,
                        );
                        await _fetchEarnings();
                        if (mounted) {
                          AppToast.showSuccess(context, 'Payout details updated successfully!');
                        }
                      } catch (e) {
                        setState(() => _isLoading = false);
                        if (mounted) {
                          AppToast.showError(context, e, fallback: 'Failed to update payout details.');
                        }
                      }
                    },
                    child: Text(
                      'Save & Verify',
                      style: AppTypography.labelLarge.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? const CustomBackButton()
            : null,
        title: Text(
          'Earnings',
          style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.pushNamed(context, UserProfileScreen.routeName);
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryFixed,
                child: Icon(PhosphorIcons.user, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.gutter),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchEarnings,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchEarnings,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.gutter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOTAL EARNED', style: AppTypography.labelCaps),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₵${_totalEarned.toStringAsFixed(2)}',
                                    style: AppTypography.displayMedium.copyWith(
                                      color: AppColors.accentBlue,
                                      fontSize: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Payout settled', style: AppTypography.bodyMedium),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    PhosphorIcons.checkCircle,
                                    color: AppColors.success,
                                    size: 18,
                                  ),
                                  Text(
                                    ' Updated after job completion',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFB800).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(PhosphorIcons.info, color: Color(0xFFB55D00)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'CraftMatch does not process payments. Agree payment directly with each client.',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: const Color(0xFF5D4037),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Payout History',
                          style: AppTypography.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        if (_history.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 48,
                                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No payouts recorded yet',
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Complete jobs to start earning!',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _history.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = _history[index];
                              final title = item['title'] as String? ?? 'Service Rendered';
                              final dateStr = item['completed_at'] as String? ?? '';
                              final date = dateStr.isNotEmpty
                                  ? dateStr.split('T').first
                                  : 'Completed';
                              final gross = (item['gross_amount'] as num?)?.toDouble() ?? 0.0;
                              final fee = (item['platform_fee'] as num?)?.toDouble() ?? 0.0;
                              final payout = (item['artisan_payout'] as num?)?.toDouble() ?? 0.0;

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
                                            style: AppTypography.bodyLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '+₵${payout.toStringAsFixed(2)}',
                                          style: AppTypography.bodyLarge.copyWith(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Date: $date',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Divider(color: AppColors.borderSubtle, height: 1),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Gross Amount: ₵${gross.toStringAsFixed(2)}',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          'Fee (10%): -₵${fee.toStringAsFixed(2)}',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        OutlinedButton.icon(
                          onPressed: () {
                            WorkerScope.of(context).setProfilePage(WorkerProfilePage.history);
                          },
                          icon: Icon(PhosphorIcons.clockCounterClockwise),
                          label: const Text('View history'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Card(
                          margin: EdgeInsets.zero,
                          color: AppColors.primaryContainer.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Icon(PhosphorIcons.wallet, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Payout Destination',
                                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_payoutDetails != null) ...[
                                  Text(
                                    'Network: ${_payoutDetails!['network']}',
                                    style: AppTypography.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'MoMo Number: ${_payoutDetails!['account_number']}',
                                    style: AppTypography.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Account Holder: ${_payoutDetails!['account_name']}',
                                    style: AppTypography.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  OutlinedButton(
                                    onPressed: _showPayoutSetupSheet,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: AppColors.primary),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text(
                                      'Change Payout Account',
                                      style: TextStyle(color: AppColors.primary),
                                    ),
                                  ),
                                ] else ...[
                                  const Text(
                                    'Setup your Mobile Money account details below to receive automatic payouts instantly upon job completions.',
                                    style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _showPayoutSetupSheet,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Setup Payout Account', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
