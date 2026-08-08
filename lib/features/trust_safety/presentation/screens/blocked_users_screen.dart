import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../services/reports_service.dart';

import '../../../../shared/widgets/custom_app_bar.dart';

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
      final blocks = await ReportsService.instance.getBlockedUsers();
      setState(() {
        _blocks = blocks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _unblockUser(String blockedId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Unblock $name?'),
        content: Text(
          'Unblocking $name will allow them to view your profile and contact you again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Blocked Accounts',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _loadBlocks, child: const Text('Retry')),
                    ],
                  ),
                )
              : _blocks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.userMinus,
                              size: 56, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('No Blocked Accounts',
                              style: AppTypography.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Accounts you block will appear here.',
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _blocks.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _blocks[index];
                        final blockedUser = item['blocked'] as Map<String, dynamic>?;
                        final name = blockedUser?['full_name'] as String? ?? 'User';
                        final avatarUrl = blockedUser?['avatar_url'] as String?;
                        final blockedId = item['blocked_id'] as String;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          leading: CircleAvatar(
                            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null || avatarUrl.isEmpty
                                ? Text(name.isNotEmpty ? name[0] : 'U')
                                : null,
                          ),
                          title: Text(name, style: AppTypography.titleSmall),
                          subtitle: Text(
                            item['reason'] != null && (item['reason'] as String).isNotEmpty
                                ? 'Reason: ${item['reason']}'
                                : 'Blocked on platform',
                            style: AppTypography.caption,
                          ),
                          trailing: OutlinedButton(
                            onPressed: () => _unblockUser(blockedId, name),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                            ),
                            child: const Text('Unblock'),
                          ),
                        );
                      },
                    ),
    );
  }
}
