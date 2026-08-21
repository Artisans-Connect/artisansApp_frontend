import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/core/services/platform_service.dart';

class ChatComposer extends StatefulWidget {
  final TextEditingController controller;
  final bool isSending;
  final bool isUploadingMedia;
  final VoidCallback onSend;
  final Function(ImageSource source, bool video) onPickAttachment;

  const ChatComposer({
    super.key,
    required this.controller,
    required this.isSending,
    required this.isUploadingMedia,
    required this.onSend,
    required this.onPickAttachment,
  });

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  bool _showAttachmentMenu = false;

  void _toggleAttachmentMenu() {
    setState(() => _showAttachmentMenu = !_showAttachmentMenu);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(
            12,
            10,
            12,
            10 + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.outlineVariant, width: 0.5),
            ),
          ),
          child: Row(
            children: <Widget>[
              // Attachment button
              Material(
                color: AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(99),
                child: InkWell(
                  onTap: widget.isUploadingMedia ? null : _toggleAttachmentMenu,
                  borderRadius: BorderRadius.circular(99),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      _showAttachmentMenu ? PhosphorIcons.x : PhosphorIcons.plus,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Text field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDim,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color: AppColors.outline,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted: (_) => widget.onSend(),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          PhosphorIcons.smiley,
                          color: AppColors.outline,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send button
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(99),
                child: InkWell(
                  onTap: widget.isSending ? null : widget.onSend,
                  borderRadius: BorderRadius.circular(99),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: widget.isSending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            PhosphorIcons.paperPlaneRight,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showAttachmentMenu)
          Positioned(
            bottom: 74,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    onPressed: widget.isUploadingMedia
                        ? null
                        : () {
                            _toggleAttachmentMenu();
                            widget.onPickAttachment(ImageSource.gallery, true);
                          },
                    icon: Icon(PhosphorIcons.video, color: AppColors.primary),
                    tooltip: 'Video',
                  ),
                  if (PlatformService.supportsCamera)
                    IconButton(
                      onPressed: widget.isUploadingMedia
                          ? null
                          : () {
                              _toggleAttachmentMenu();
                              widget.onPickAttachment(ImageSource.camera, false);
                            },
                      icon: Icon(PhosphorIcons.camera, color: AppColors.primary),
                      tooltip: 'Camera',
                    ),
                  IconButton(
                    onPressed: widget.isUploadingMedia
                        ? null
                        : () {
                            _toggleAttachmentMenu();
                            widget.onPickAttachment(ImageSource.gallery, false);
                          },
                    icon: Icon(PhosphorIcons.image, color: AppColors.primary),
                    tooltip: 'Gallery',
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
