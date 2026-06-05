import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:artisans_app/core/theme/index.dart';
import '../models/chat_message.dart';

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

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          crossAxisAlignment:
              message.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isMine ? AppColors.primary : const Color(0xFFEEECF5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isMine ? 20 : 6),
                  bottomRight: Radius.circular(message.isMine ? 6 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (_mediaItems.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _mediaItems.map(_buildMedia).toList(),
                      ),
                    ),
                  if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      style: AppTypography.bodyLg.copyWith(
                        color: message.isMine ? Colors.white : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    _formatTime(message.sentAt),
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  if (message.isMine) ...<Widget>[
                    const SizedBox(width: 4),
                    Icon(
                      message.status == MessageStatus.pending
                          ? PhosphorIcons.clock
                          : message.status == MessageStatus.failed
                              ? PhosphorIcons.warningCircle
                              : PhosphorIcons.checks,
                      size: 14,
                      color: message.status == MessageStatus.failed
                          ? Colors.redAccent
                          : AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_BubbleMedia> get _mediaItems {
    final List<_BubbleMedia> items = <_BubbleMedia>[];
    final List<String> urls = message.mediaUrls ?? <String>[];
    final List<String> types = message.mediaTypes ?? <String>[];
    for (int i = 0; i < urls.length; i++) {
      items.add(_BubbleMedia(urls[i], i < types.length ? types[i] : 'image'));
    }
    for (final String url in message.imageUrls ?? <String>[]) {
      if (!items.any((_BubbleMedia item) => item.url == url)) {
        items.add(_BubbleMedia(url, 'image'));
      }
    }
    return items;
  }

  Widget _buildMedia(_BubbleMedia media) {
    if (media.type == 'video') {
      return InkWell(
        onTap: () => launchUrl(Uri.parse(media.url), mode: LaunchMode.externalApplication),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 160,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              PhosphorIcons.playCircle,
              color: message.isMine ? Colors.white : AppColors.primary,
              size: 34,
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        media.url,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final int hour = dt.hour;
    final int minute = dt.minute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}

class _BubbleMedia {
  const _BubbleMedia(this.url, this.type);

  final String url;
  final String type;
}
