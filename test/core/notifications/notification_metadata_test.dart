import 'package:artisans_app/core/notifications/notification_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classifies action-required notifications from metadata', () {
    final metadata = NotificationMetadata.fromData(<String, dynamic>{
      'type': 'job_completion_submitted',
      'priority': 'action_required',
      'route': 'client_live_tracking',
      'actionLabel': 'Review work',
      'jobId': 'job-123',
      'jobTitle': 'Fix leaking bathroom tap',
    });

    expect(metadata.type, 'job_completion_submitted');
    expect(metadata.priority, NotificationPriority.actionRequired);
    expect(metadata.route, NotificationRouteTarget.clientLiveTracking);
    expect(metadata.actionLabel, 'Review work');
    expect(metadata.jobId, 'job-123');
    expect(metadata.jobTitle, 'Fix leaking bathroom tap');
    expect(metadata.isActionRequired, true);
  });

  test('falls back to known type metadata when backend metadata is absent', () {
    final metadata = NotificationMetadata.fromData(<String, dynamic>{
      'type': 'new_job',
      'jobId': 'job-456',
    });

    expect(metadata.priority, NotificationPriority.actionRequired);
    expect(metadata.route, NotificationRouteTarget.workerJobRequest);
    expect(metadata.actionLabel, 'View request');
    expect(metadata.groupKey, 'job:job-456');
  });

  test('uses chat detail route when chat notification includes a job id', () {
    final metadata = NotificationMetadata.fromData(<String, dynamic>{
      'type': 'chat_message',
      'jobId': 'job-789',
      'actorName': 'Ama',
    });

    expect(metadata.priority, NotificationPriority.info);
    expect(metadata.route, NotificationRouteTarget.chatDetail);
    expect(metadata.actionLabel, 'Reply');
    expect(metadata.jobId, 'job-789');
    expect(metadata.actorName, 'Ama');
  });
}
