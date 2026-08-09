import 'package:flutter/material.dart';

class ConfirmWorkDoneDialog extends StatelessWidget {
  const ConfirmWorkDoneDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Work Finished?'),
      content: const Text(
        'Confirming that the artisan has completed the work will stop the work timer. The artisan will then submit the settlement breakdown.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Not Yet'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Yes, Confirm'),
        ),
      ],
    );
  }
}
