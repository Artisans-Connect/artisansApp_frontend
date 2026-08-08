import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/picked_media.dart';
import '../../domain/models/report_category.dart';
import '../../domain/models/report_model.dart';
import '../../services/reports_service.dart';

class ReportSubmissionBottomSheet extends StatefulWidget {
  const ReportSubmissionBottomSheet({
    super.key,
    this.reportedId,
    this.reportedName,
    this.bookingId,
    this.chatId,
    this.initialCategory,
  });

  final String? reportedId;
  final String? reportedName;
  final String? bookingId;
  final String? chatId;
  final ReportCategory? initialCategory;

  static Future<SafetyReport?> show(
    BuildContext context, {
    String? reportedId,
    String? reportedName,
    String? bookingId,
    String? chatId,
    ReportCategory? initialCategory,
  }) {
    return showModalBottomSheet<SafetyReport>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportSubmissionBottomSheet(
        reportedId: reportedId,
        reportedName: reportedName,
        bookingId: bookingId,
        chatId: chatId,
        initialCategory: initialCategory,
      ),
    );
  }

  @override
  State<ReportSubmissionBottomSheet> createState() =>
      _ReportSubmissionBottomSheetState();
}

class _ReportSubmissionBottomSheetState
    extends State<ReportSubmissionBottomSheet> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  ReportCategory? _selectedCategory;
  bool _isEmergency = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  final List<PickedMedia> _evidenceFiles = [];

  static const int minCharLimit = 10;
  static const int maxCharLimit = 1000;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickEvidenceImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (file != null) {
        final media = await PickedMedia.fromXFile(file);
        setState(() {
          _evidenceFiles.add(media);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to attach image.')),
      );
    }
  }

  Future<void> _callEmergencyServices() async {
    final Uri url = Uri.parse('tel:112');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer. Please dial 112 directly.')),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (_selectedCategory == null) {
      setState(() => _errorMessage = 'Please select a report category.');
      return;
    }

    final text = _descriptionController.text.trim();
    if (text.length < minCharLimit) {
      setState(() => _errorMessage =
          'Please provide a detailed description (at least $minCharLimit characters).');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final report = await ReportsService.instance.submitReport(
        category: _selectedCategory!,
        description: text,
        reportedId: widget.reportedId,
        bookingId: widget.bookingId,
        chatId: widget.chatId,
        isEmergency: _isEmergency,
        evidenceFiles: _evidenceFiles,
      );

      if (!mounted) return;
      Navigator.pop(context, report);
      _showConfirmationDialog(report);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _showConfirmationDialog(SafetyReport report) {
    final navContext = Navigator.of(context).context;
    showDialog<void>(
      context: navContext,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              report.isEmergency
                  ? PhosphorIcons.warningDiamondFill
                  : PhosphorIcons.checkCircleFill,
              color: report.isEmergency ? AppColors.error : AppColors.success,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                report.isEmergency
                    ? 'Emergency Priority Flagged'
                    : 'Report Submitted',
                style: AppTypography.titleLarge,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket Number: ${report.ticketNumber}',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              report.isEmergency
                  ? 'Your report has been marked as high-priority emergency and sent to our senior Trust & Safety escalation team for immediate review.'
                  : 'Thank you for helping keep CraftMatch safe. Our Trust & Safety team is reviewing your report.',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.shieldCheck,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your identity remains 100% confidential and is never shared with the reported user.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final charLength = _descriptionController.text.trim().length;

    return Container(
      constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: mediaQuery.viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar & Header
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
                Icon(PhosphorIcons.shieldWarning,
                    color: AppColors.primary, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trust & Safety Report',
                          style: AppTypography.titleLarge),
                      if (widget.reportedName != null)
                        Text(
                          'Reporting: ${widget.reportedName}',
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

            // Emergency Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFA39E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(PhosphorIcons.warningCircleFill,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Immediate Danger?',
                        style: AppTypography.titleSmall
                            .copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'If you or someone else is in immediate physical danger, please contact local emergency services immediately.',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _callEmergencyServices,
                        icon: const Icon(PhosphorIcons.phoneCall, size: 16),
                        label: const Text('Call Emergency (112)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isEmergency,
                              activeColor: AppColors.error,
                              onChanged: (val) {
                                setState(() {
                                  _isEmergency = val ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                'Mark as Emergency Report',
                                style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step 1: Select Category
            Text('1. Select Category', style: AppTypography.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReportCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  avatar: Icon(
                    cat.icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  label: Text(cat.label),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? cat : null;
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedCategory != null) ...[
              const SizedBox(height: 8),
              Text(
                _selectedCategory!.description,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
              ),
            ],

            const SizedBox(height: 20),

            // Step 2: Description & Character Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('2. Detailed Description', style: AppTypography.titleMedium),
                Text(
                  '$charLength / $maxCharLimit',
                  style: AppTypography.caption.copyWith(
                    color: charLength > maxCharLimit
                        ? AppColors.error
                        : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: maxCharLimit,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText:
                    'Please describe what happened in detail (date, location, exact interactions, etc.)…',
                counterText: '',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Step 3: Attach Evidence (Photos, Screenshots, Documents)
            Text('3. Attach Evidence (Optional)',
                style: AppTypography.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Upload relevant photos, chat screenshots, or documents.',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickEvidenceImage(ImageSource.gallery),
                  icon: const Icon(PhosphorIcons.image, size: 18),
                  label: const Text('Gallery'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _pickEvidenceImage(ImageSource.camera),
                  icon: const Icon(PhosphorIcons.camera, size: 18),
                  label: const Text('Camera'),
                ),
              ],
            ),

            if (_evidenceFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _evidenceFiles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final media = _evidenceFiles[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            media.bytes,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _evidenceFiles.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xB3000000),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.error),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Submit Button
            FilledButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: FilledButton.styleFrom(
                backgroundColor:
                    _isEmergency ? AppColors.error : AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _isEmergency
                          ? 'SUBMIT EMERGENCY REPORT'
                          : 'SUBMIT SAFETY REPORT',
                      style: AppTypography.button.copyWith(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
