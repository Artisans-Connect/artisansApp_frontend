import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/services/wallet_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../../../shared/widgets/gradient_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, this.isWorker = false});

  final bool isWorker;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  final WalletService _walletService = WalletService.instance;
  late TabController _tabController;

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _walletData;
  List<Map<String, dynamic>> _transactions = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWallet();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWallet() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _walletService.getWallet();
      if (!mounted) return;
      final wallet = res['wallet'] as Map<String, dynamic>?;
      final rawTx = res['transactions'] as List?;
      setState(() {
        _walletData = wallet;
        _transactions = rawTx != null
            ? rawTx.cast<Map<String, dynamic>>()
            : <Map<String, dynamic>>[];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load wallet. Please try again.';
      });
    }
  }

  List<Map<String, dynamic>> _filteredTransactions(int tabIndex) {
    if (tabIndex == 0) return _transactions;
    if (tabIndex == 1) {
      return _transactions
          .where((tx) => tx['type'] == 'deposit' || tx['type'] == 'refund')
          .toList();
    }
    if (tabIndex == 2) {
      return _transactions
          .where((tx) => tx['type'] == 'escrow_release' || tx['type'] == 'escrow_lock')
          .toList();
    }
    return _transactions.where((tx) => tx['type'] == 'payout').toList();
  }

  void _showTopupModal() {
    final TextEditingController amountController = TextEditingController(text: '50');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.gutter,
          right: AppSpacing.gutter,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Top-Up Wallet', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add funds to your CraftMatch credit balance for instant payments.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (GHS)',
                prefixText: 'GHS ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(
              label: 'Proceed to Deposit',
              onPressed: () async {
                final double? amt = double.tryParse(amountController.text);
                if (amt == null || amt <= 0) {
                  AppToast.showError(context, 'Please enter a valid deposit amount.');
                  return;
                }
                Navigator.pop(ctx);
                final String ref = 'cm_pay_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(9000) + 1000}';
                try {
                  await _walletService.topupWallet(amount: amt, reference: ref);
                  if (!mounted) return;
                  AppToast.showPayment(context, '💳 GH\u20B5 ${amt.toStringAsFixed(2)} added to your CraftMatch wallet!');
                  _loadWallet();
                } catch (e) {
                  if (!mounted) return;
                  AppToast.showError(context, 'Top-up failed. Please try again.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCashoutModal() {
    final TextEditingController amountController = TextEditingController(text: '100');
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    String selectedProvider = 'MTN';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.gutter,
            right: AppSpacing.gutter,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.isWorker ? 'Cash Out Earnings' : 'Cash Out Balance',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.isWorker
                    ? 'Withdraw your available balance to your Mobile Money account.'
                    : 'Withdraw your available credits or refunds to your Mobile Money account.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Withdrawal Amount (GHS)',
                  prefixText: 'GHS ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: selectedProvider,
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'MTN', child: Text('MTN Mobile Money')),
                  DropdownMenuItem(value: 'TELECEL', child: Text('Telecel Cash')),
                  DropdownMenuItem(value: 'AT', child: Text('AT Money')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedProvider = val);
                },
                decoration: InputDecoration(
                  labelText: 'Mobile Money Provider',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'MoMo Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Account Registered Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GradientButton(
                label: 'Request Cash-Out',
                onPressed: () async {
                  final double? amt = double.tryParse(amountController.text);
                  if (amt == null || amt <= 0) {
                    AppToast.showError(context, 'Please enter a valid withdrawal amount.');
                    return;
                  }
                  if (phoneController.text.trim().isEmpty || nameController.text.trim().isEmpty) {
                    AppToast.showError(context, 'Please enter phone number and account name.');
                    return;
                  }
                  Navigator.pop(ctx);
                  try {
                    await _walletService.requestPayout(
                      amount: amt,
                      channel: 'momo',
                      accountNumber: phoneController.text.trim(),
                      accountName: nameController.text.trim(),
                      bankCode: selectedProvider,
                    );
                    if (!mounted) return;
                    AppToast.showSuccess(context, 'Cash-out request of GHS ${amt.toStringAsFixed(2)} submitted!');
                    _loadWallet();
                  } catch (e) {
                    if (!mounted) return;
                    AppToast.showError(context, e, fallback: 'Cash-out failed.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double balance = double.tryParse(_walletData?['balance']?.toString() ?? '0') ?? 0.00;
    final double heldBalance = double.tryParse(_walletData?['held_balance']?.toString() ?? '0') ?? 0.00;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'My Wallet',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorStateView(
                  message: _error!,
                  onRetry: _loadWallet,
                )
              : RefreshIndicator(
                  onRefresh: _loadWallet,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Balance Hero Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.isWorker
                                  ? <Color>[const Color(0xFF2C2418), const Color(0xFF4A3E2F)]
                                  : <Color>[const Color(0xFF8B3A2A), const Color(0xFFC15A3D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: widget.isWorker
                                    ? AppColors.textPrimary.withOpacity(0.25)
                                    : AppColors.primaryDark.withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'AVAILABLE BALANCE',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white70,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'GHS ${balance.toStringAsFixed(2)}',
                                style: AppTypography.displayMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (heldBalance > 0) ...<Widget>[
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      PhosphorIcons.lockKey,
                                      color: Colors.amberAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'GHS ${heldBalance.toStringAsFixed(2)} held in active escrow',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: Colors.amberAccent,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _showTopupModal,
                                      icon: const Icon(PhosphorIcons.plusCircle, size: 18),
                                      label: const Text('Top-Up'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: widget.isWorker
                                            ? AppColors.primary
                                            : AppColors.secondary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _showCashoutModal,
                                      icon: const Icon(PhosphorIcons.arrowUpRight, size: 18),
                                      label: const Text('Cash Out'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: widget.isWorker
                                            ? AppColors.secondary
                                            : Colors.white.withOpacity(0.9),
                                        foregroundColor: widget.isWorker
                                            ? Colors.white
                                            : AppColors.primary,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Transaction Ledger', style: AppTypography.titleLarge),
                        const SizedBox(height: AppSpacing.sm),
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          onTap: (_) => setState(() {}),
                          tabs: const <Tab>[
                            Tab(text: 'All'),
                            Tab(text: 'Deposits & Refunds'),
                            Tab(text: 'Escrow Releases'),
                            Tab(text: 'Payouts'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Builder(
                          builder: (context) {
                            final txs = _filteredTransactions(_tabController.index);
                            if (txs.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                                child: Center(
                                  child: Text(
                                    'No transactions found for this filter.',
                                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                                  ),
                                ),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: txs.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (ctx, index) {
                                final tx = txs[index];
                                final double amt = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.00;
                                final bool isPositive = amt > 0;
                                final String type = (tx['type'] as String? ?? '').toLowerCase();

                                IconData icon = PhosphorIcons.receipt;
                                Color iconColor = AppColors.primary;

                                if (type == 'deposit') {
                                  icon = PhosphorIcons.arrowDownLeft;
                                  iconColor = const Color(0xFF10B981);
                                } else if (type == 'refund') {
                                  icon = PhosphorIcons.arrowCounterClockwise;
                                  iconColor = Colors.blue;
                                } else if (type == 'escrow_release') {
                                  icon = PhosphorIcons.checkCircle;
                                  iconColor = const Color(0xFF10B981);
                                } else if (type == 'payout') {
                                  icon = PhosphorIcons.paperPlaneRight;
                                  iconColor = Colors.purple;
                                }

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  leading: CircleAvatar(
                                    backgroundColor: iconColor.withValues(alpha: 0.1),
                                    child: Icon(icon, color: iconColor, size: 20),
                                  ),
                                  title: Text(
                                    tx['description'] as String? ?? tx['type'] as String? ?? 'Transaction',
                                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    (tx['created_at'] as String? ?? '').split('T').first,
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                  ),
                                  trailing: Text(
                                    '${isPositive ? '+' : ''}GHS ${amt.abs().toStringAsFixed(2)}',
                                    style: AppTypography.labelLarge.copyWith(
                                      color: isPositive ? const Color(0xFF10B981) : const Color(0xFFE11D48),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
