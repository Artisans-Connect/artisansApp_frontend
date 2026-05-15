import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../models/chat_message.dart';
import '../utils/time_format.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final Alignment alignment =
        message.isMine ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleColor =
        message.isMine ? AppColors.primary : AppColors.surfaceDim;
    final Color textColor =
        message.isMine ? Colors.white : AppColors.textPrimary;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isMine ? 20 : 4),
            bottomRight: Radius.circular(message.isMine ? 4 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.content,
              style:
                  AppTextStyles.bodyLg.copyWith(color: textColor, height: 1.35),
            ),
            const SizedBox(height: 6),
            Text(
              formatRelativeTime(message.sentAt),
              style: AppTextStyles.bodyMd.copyWith(
                color:
                    message.isMine ? Colors.white70 : AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
