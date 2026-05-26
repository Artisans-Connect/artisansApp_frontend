import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../models/conversation_summary.dart';
import '../utils/time_format.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final ConversationSummary conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = conversation.unreadCount > 0;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.surfaceDim,
                child: Text(
                  conversation.counterpartName.isNotEmpty
                      ? conversation.counterpartName[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            conversation.counterpartName,
                            style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight:
                                  hasUnread ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          formatRelativeTime(conversation.lastMessageAt),
                          style: AppTextStyles.bodyMd.copyWith(
                            color: hasUnread
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    if (conversation.jobTitle != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        conversation.jobTitle!,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.primary.withOpacity(0.85),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      conversation.lastMessagePreview,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight:
                            hasUnread ? FontWeight.w500 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (hasUnread) ...<Widget>[
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${conversation.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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
