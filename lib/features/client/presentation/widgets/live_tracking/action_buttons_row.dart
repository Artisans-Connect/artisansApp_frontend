import 'package:flutter/material.dart';
import 'tracking_atoms.dart';
import '../../navigation/client_navigation.dart';

class ActionButtonsRow extends StatelessWidget {
  final Map<String, dynamic> job;
  final String? jobUuid;
  final String? workerId;

  const ActionButtonsRow({
    super.key,
    required this.job,
    this.jobUuid,
    this.workerId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ActionButton(
            icon: Icons.phone_rounded,
            label: 'Call',
            isEnabled: job['phone'] != null,
            onTap: job['phone'] != null
                ? () => ClientNavigation.callPhone(context, job['phone'] as String)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActionButton(
            icon: Icons.chat_bubble_rounded,
            label: 'Message',
            isEnabled: jobUuid != null,
            onTap: jobUuid != null
                ? () => ClientNavigation.openChat(
                      context,
                      conversationId: jobUuid!,
                      counterpartUserId:
                          job['counterpartUserId'] as String? ?? workerId ?? '',
                      counterpartName: job['artisan'] as String? ?? 'Artisan',
                      jobId: jobUuid!,
                      jobTitle: job['title'] as String?,
                    )
                : null,
          ),
        ),
      ],
    );
  }
}
