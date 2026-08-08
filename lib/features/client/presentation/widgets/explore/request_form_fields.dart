import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';

class RequestFormFields extends StatelessWidget {
  const RequestFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.onChanged,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Request title'),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'What do you need done?'),
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}
