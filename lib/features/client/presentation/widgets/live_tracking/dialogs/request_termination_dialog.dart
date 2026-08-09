import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_tokens.dart';

class RequestTerminationDialog extends StatefulWidget {
  const RequestTerminationDialog({super.key});

  @override
  State<RequestTerminationDialog> createState() => _RequestTerminationDialogState();
}

class _RequestTerminationDialogState extends State<RequestTerminationDialog> {
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
      title: const Row(
        children: [
          Icon(
            Icons.front_hand_rounded,
            color: DesignTokens.accentWarm,
            size: 24,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Request Termination',
              style: TextStyle(
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
            const Text(
              'Work has already started. Your artisan will be notified and can accept or decline the termination.',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14,
                color: DesignTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DesignTokens.accentWarm.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Note: This is not an instant cancellation. The artisan must agree to stop work.',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12,
                  color: DesignTokens.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Why do you want to terminate this job?',
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
          style: FilledButton.styleFrom(
              backgroundColor: DesignTokens.accentWarm),
          onPressed: () => Navigator.pop(context, _reasonCtrl.text.trim()),
          child: const Text('Request Termination'),
        ),
      ],
    );
  }
}
