import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/features/trust_safety/presentation/widgets/report_submission_bottom_sheet.dart';

class SafetyHelpBottomSheet extends StatelessWidget {
  const SafetyHelpBottomSheet({
    super.key,
    this.bookingId,
    this.otherUserId,
    this.otherUserName,
    this.jobTitle,
  });

  final String? bookingId;
  final String? otherUserId;
  final String? otherUserName;
  final String? jobTitle;

  static void show(
    BuildContext context, {
    String? bookingId,
    String? otherUserId,
    String? otherUserName,
    String? jobTitle,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SafetyHelpBottomSheet(
        bookingId: bookingId,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        jobTitle: jobTitle,
      ),
    );
  }

  Future<void> _callEmergency(BuildContext context) async {
    final Uri url = Uri.parse('tel:112');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer. Please dial 112 directly.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(PhosphorIcons.shieldCheckFill,
                  color: AppColors.primary, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Safety & Support Center',
                        style: AppTypography.titleLarge),
                    if (jobTitle != null)
                      Text(
                        'Active Job: $jobTitle',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(height: 24),

          // Immediate Emergency Button
          InkWell(
            onTap: () {
              Navigator.pop(context);
              _callEmergency(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(PhosphorIcons.phoneCall,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Call Emergency Services (112)',
                          style: AppTypography.titleSmall
                              .copyWith(color: AppColors.error),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Immediate connection for police, medical, or fire emergency.',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  Icon(PhosphorIcons.caretRight,
                      color: AppColors.error, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Report Safety Incident / Concern
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: AppColors.surface,
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(PhosphorIcons.warningCircle,
                  color: AppColors.primary, size: 22),
            ),
            title: Text('Report a Safety Concern',
                style: AppTypography.titleSmall),
            subtitle: Text(
              'Report harassment, fraud, property damage, or suspicious behavior.',
              style: AppTypography.caption,
            ),
            trailing: const Icon(PhosphorIcons.caretRight, size: 18),
            onTap: () {
              Navigator.pop(context);
              ReportSubmissionBottomSheet.show(
                context,
                bookingId: bookingId,
                reportedId: otherUserId,
                reportedName: otherUserName,
              );
            },
          ),

          const SizedBox(height: 8),

          // In-Home Safety Tips Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(PhosphorIcons.info,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('In-Home Safety Advice',
                        style: AppTypography.titleSmall),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '• Keep payments within the CraftMatch app to maintain full escrow protection.\n'
                  '• Verify identity before allowing entry into private residences.\n'
                  '• Keep emergency contacts accessible during live jobs.',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
