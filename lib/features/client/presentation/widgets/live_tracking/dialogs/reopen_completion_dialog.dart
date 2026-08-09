import 'package:flutter/material.dart';

class ReopenCompletionDialog extends StatefulWidget {
  const ReopenCompletionDialog({super.key});

  @override
  State<ReopenCompletionDialog> createState() =>
      _ReopenCompletionDialogState();
}

class _ReopenCompletionDialogState extends State<ReopenCompletionDialog> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Job not done?'),
      content: TextField(
        controller: _noteController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Tell the artisan what still needs attention.',
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _noteController.text.trim()),
          child: const Text('Reopen job'),
        ),
      ],
    );
  }
}
