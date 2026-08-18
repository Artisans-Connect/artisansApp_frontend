import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/utils/shared_user_context.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../services/reports_service.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  static const String routeName = '/blocked-users';

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _blocks = [];

  bool get _isWorkerView =>
      SharedUserContext.isViewingAsWorker || SharedUserContext.isWorker;

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  Future<void> _loadBlocks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String roleFilter = _isWorkerView ? 'client' : 'worker';
      final blocks = await ReportsService.instance.getBlockedUsers(role: roleFilter);
      setState(() {
        _blocks = blocks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = userMessageFor(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _unblockUser(String blockedId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Unblock $name?',
          style: const TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Unblocking $name will allow them to view your profile, send job leads, and contact you again.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ReportsService.instance.unblockUser(blockedId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unblocked $name successfully.')),
      );
      _loadBlocks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unblock: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWorker = _isWorkerView;
    final String pageTitle = isWorker ? 'Blocked Clients' : 'Blocked Artisans';
    final String pageSubtitle = isWorker
        ? 'Restricted Clients & Dispatch Safeguards'
        : 'Restricted Artisans & Safety Controls';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: pageTitle,
        subtitle: pageSubtitle,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          PhosphorIcons.warningCircle,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _loadBlocks,
                          icon: const Icon(PhosphorIcons.arrowClockwise),
                          label: const Text('Retry'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBlocks,
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    children: [
                      // Caution Banner
                      _buildCautionBanner(isWorker),
                      const SizedBox(height: 16),

                      // Section Header with count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isWorker
                                ? 'Restricted Clients (${_blocks.length})'
                                : 'Restricted Artisans (${_blocks.length})',
                            style: const TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.shieldWarning,
                                  size: 13,
                                  color: Color(0xFFDC2626),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Restricted',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Empty state or list
                      if (_blocks.isEmpty)
                        _buildEmptyState(isWorker)
                      else
                        ..._blocks.map((item) => _buildBlockedCard(item, isWorker)),

                      const SizedBox(height: 20),

                      // Bottom Trust & Safety Advisory Card
                      _buildTrustAdvisory(isWorker),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCautionBanner(bool isWorker) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Amber 50
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)), // Amber 200
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: const Icon(
              PhosphorIcons.shieldWarning,
              size: 24,
              color: Color(0xFFB45309), // Amber 700
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWorker
                      ? 'Client Restriction & Safeguards'
                      : 'Artisan Caution & Safety Notice',
                  style: const TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E), // Amber 800
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isWorker
                      ? 'Dispatch requests, quote invitations, and messages from these client accounts are prevented to protect your wages and personal safety.'
                      : 'These artisans are blocked and cannot accept your job dispatches or message you. Never contract or pay unverified technicians outside CraftMatch.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isWorker) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryTint08,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              PhosphorIcons.shieldCheck,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isWorker ? 'No Blocked Clients' : 'No Blocked Artisans',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            isWorker
                ? 'Your client interactions and dispatch leads are all in good standing.'
                : 'You have no blocked artisans. Any restricted technicians will be safely listed here.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedCard(Map<String, dynamic> item, bool isWorker) {
    final blockedUser = item['blocked'] as Map<String, dynamic>?;
    final name = blockedUser?['full_name'] as String? ?? 'Restricted Profile';
    final avatarUrl = blockedUser?['avatar_url'] as String?;
    final phone = blockedUser?['phone'] as String?;
    final blockedId = item['blocked_id'] as String? ?? '';
    final isPersonalBlock = item['is_personal_block'] == true;
    final reason = (item['reason'] as String?)?.trim();

    // Worker metadata if present
    final workerData = blockedUser?['workers'];
    final Map<String, dynamic>? workerMap = workerData is List
        ? (workerData.isNotEmpty ? workerData.first as Map<String, dynamic>? : null)
        : (workerData is Map<String, dynamic> ? workerData : null);

    final List<String> skills = (workerMap?['skills'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final double rating = (workerMap?['rating'] is num)
        ? (workerMap!['rating'] as num).toDouble()
        : 0.0;
    final int totalJobs = (workerMap?['total_jobs'] is num)
        ? (workerMap!['total_jobs'] as num).toInt()
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFEE2E2), // subtle red-100 border for caution
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header Row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with caution overlay
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFFEE2E2),
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB91C1C),
                                fontSize: 18,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: -1,
                      right: -1,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          PhosphorIcons.warning,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Name & Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: isPersonalBlock
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isPersonalBlock
                                    ? const Color(0xFFFECACA)
                                    : const Color(0xFFFFEDD5),
                              ),
                            ),
                            child: Text(
                              isPersonalBlock ? 'Blocked by You' : 'Platform Suspended',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isPersonalBlock
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFFC2410C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Worker or Client Meta details
                      if (!isWorker && skills.isNotEmpty) ...[
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: skills.map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                skill,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Stats or Contact Info
                      Row(
                        children: [
                          if (!isWorker && totalJobs > 0) ...[
                            const Icon(
                              PhosphorIcons.star,
                              size: 13,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              rating > 0 ? rating.toStringAsFixed(1) : 'New',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•  $totalJobs jobs',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (phone != null && phone.isNotEmpty) ...[
                            const Icon(
                              PhosphorIcons.phoneSlash,
                              size: 12,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              phone,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Caution / Reason Callout Box
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2), // Red 50
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECACA)), // Red 200
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  PhosphorIcons.warningCircle,
                  size: 16,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Caution / Restriction Reason: ',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        TextSpan(
                          text: reason != null && reason.isNotEmpty
                              ? reason
                              : 'Flagged for non-compliance with platform safety and service integrity policies.',
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF7F1D1D),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action / Status bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      PhosphorIcons.lockKey,
                      size: 13,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Direct booking disabled',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (isPersonalBlock && blockedId.isNotEmpty)
                  OutlinedButton(
                    onPressed: () => _unblockUser(blockedId, name),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 32),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Unblock',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Moderated by Platform',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustAdvisory(bool isWorker) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryTint08,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              PhosphorIcons.shieldCheck,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWorker
                      ? 'CraftMatch Worker Safety Guarantee'
                      : 'CraftMatch Ghana Escrow Guarantee',
                  style: const TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isWorker
                      ? 'Never accept cash or start jobs before the client milestone is secured in escrow. Report any payment coercion directly to Support.'
                      : 'All verified artisans are KYC checked with Ghana Card. Keep all payments in Milestone Escrow until job is fully complete.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
