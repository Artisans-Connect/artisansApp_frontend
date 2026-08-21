import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/design_tokens.dart';

class CancelJobDialog extends StatefulWidget {
  final double fee;
  final String warningTitle;
  final String warningMessage;

  const CancelJobDialog({
    super.key,
    required this.fee,
    required this.warningTitle,
    required this.warningMessage,
  });

  @override
  State<CancelJobDialog> createState() => _CancelJobDialogState();
}

class _CancelJobDialogState extends State<CancelJobDialog> {
  late final TextEditingController _reasonCtrl;

  @override
  void initState() {
    super.initState();
    _reasonCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Row(
        children: [
          Icon(
            widget.fee > 0 ? Icons.warning_amber_rounded : Icons.cancel_outlined,
            color: widget.fee > 0 ? DesignTokens.accentWarm : DesignTokens.error,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.warningTitle,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.warningMessage,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14,
                color: DesignTokens.textSecondary,
              ),
            ),
            if (widget.fee > 0) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignTokens.accentWarm.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: DesignTokens.accentWarm.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_rounded,
                        color: DesignTokens.accentWarm, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'GH\u20B5 ${widget.fee.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: DesignTokens.accentWarm,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please pay this amount directly to the artisan.',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12,
                  color: DesignTokens.textSecondary.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _reasonCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Reason for cancellation (optional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Keep Job'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: DesignTokens.error),
          onPressed: () => Navigator.pop(context, _reasonCtrl.text.trim()),
          child: const Text('Yes, Cancel'),
        ),
      ],
    );
  }
}
