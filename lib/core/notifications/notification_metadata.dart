enum NotificationPriority {
  actionRequired,
  status,
  info,
}

enum NotificationRouteTarget {
  workerJobRequest,
  workerActiveBooking,
  clientJobApplicants,
  clientLiveTracking,
  chatDetail,
  notifications,
}

class NotificationMetadata {
  const NotificationMetadata({
    required this.type,
    required this.priority,
    required this.route,
    required this.actionLabel,
    this.jobId,
    this.actorId,
    this.actorName,
    this.jobTitle,
    this.groupKey,
  });

  factory NotificationMetadata.fromData(Map<String, dynamic>? data,
      {String fallbackType = 'general'}) {
    final Map<String, dynamic> safeData = data ?? <String, dynamic>{};
    final String type = _readString(safeData['type']) ?? fallbackType;
    final String? jobId = _readString(safeData['jobId']);
    final NotificationPriority priority =
        _priorityFromString(_readString(safeData['priority'])) ??
            _fallbackPriority(type);
    final NotificationRouteTarget route =
        _routeFromString(_readString(safeData['route'])) ??
            _fallbackRoute(type);
    final String actionLabel =
        _readString(safeData['actionLabel']) ?? _fallbackActionLabel(type);

    return NotificationMetadata(
      type: type,
      priority: priority,
      route: route,
      actionLabel: actionLabel,
      jobId: jobId,
      actorId: _readString(safeData['actorId']),
      actorName: _readString(safeData['actorName']),
      jobTitle: _readString(safeData['jobTitle']),
      groupKey: _readString(safeData['groupKey']) ??
          (jobId == null ? null : 'job:$jobId'),
    );
  }

  final String type;
  final NotificationPriority priority;
  final NotificationRouteTarget route;
  final String actionLabel;
  final String? jobId;
  final String? actorId;
  final String? actorName;
  final String? jobTitle;
  final String? groupKey;

  bool get isActionRequired =>
      priority == NotificationPriority.actionRequired;

  static String? _readString(Object? value) {
    if (value == null) return null;
    final String text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static NotificationPriority? _priorityFromString(String? value) {
    switch (value) {
      case 'action_required':
        return NotificationPriority.actionRequired;
      case 'status':
        return NotificationPriority.status;
      case 'info':
        return NotificationPriority.info;
      default:
        return null;
    }
  }

  static NotificationRouteTarget? _routeFromString(String? value) {
    switch (value) {
      case 'worker_job_request':
        return NotificationRouteTarget.workerJobRequest;
      case 'worker_active_booking':
        return NotificationRouteTarget.workerActiveBooking;
      case 'client_job_applicants':
        return NotificationRouteTarget.clientJobApplicants;
      case 'client_live_tracking':
        return NotificationRouteTarget.clientLiveTracking;
      case 'chat_detail':
        return NotificationRouteTarget.chatDetail;
      case 'notifications':
        return NotificationRouteTarget.notifications;
      default:
        return null;
    }
  }

  static NotificationPriority _fallbackPriority(String type) {
    switch (type) {
      case 'new_job':
      case 'job_application_received':
      case 'job_application_accepted':
      case 'job_completion_submitted':
      case 'completion_disputed':
      case 'work_progress_checkin':
      case 'scheduled_activation_blocked':
      case 'termination_requested':
      case 'worker_cancelled_job':
        return NotificationPriority.actionRequired;
      case 'chat_message':
        return NotificationPriority.info;
      default:
        return NotificationPriority.status;
    }
  }

  static NotificationRouteTarget _fallbackRoute(String type) {
    switch (type) {
      case 'new_job':
        return NotificationRouteTarget.workerJobRequest;
      case 'job_application_received':
        return NotificationRouteTarget.clientJobApplicants;
      case 'job_application_accepted':
      case 'termination_requested':
      case 'client_cancelled_job':
      case 'job_cancelled':
      case 'completion_disputed':
      case 'scheduled_worker_reminder':
        return NotificationRouteTarget.workerActiveBooking;
      case 'chat_message':
        return NotificationRouteTarget.chatDetail;
      case 'worker_on_the_way':
      case 'worker_arrived':
      case 'job_started':
      case 'job_matched':
      case 'job_completion_submitted':
      case 'job_completed':
      case 'worker_cancelled_job':
      case 'job_expired':
      case 'scheduled_reminder':
      case 'scheduled_activation_blocked':
      case 'termination_resolved':
        return NotificationRouteTarget.clientLiveTracking;
      default:
        return NotificationRouteTarget.notifications;
    }
  }

  static String _fallbackActionLabel(String type) {
    switch (type) {
      case 'new_job':
        return 'View request';
      case 'job_application_received':
        return 'Review applicants';
      case 'job_application_accepted':
        return 'Open booking';
      case 'chat_message':
        return 'Reply';
      case 'worker_on_the_way':
        return 'Track artisan';
      case 'worker_arrived':
        return 'View status';
      case 'job_started':
        return 'View progress';
      case 'job_completion_submitted':
        return 'Review work';
      case 'job_completed':
        return 'Rate service';
      case 'worker_cancelled_job':
        return 'Find another worker';
      case 'completion_disputed':
        return 'Review job';
      case 'work_progress_checkin':
        return 'Confirm job done';
      case 'scheduled_worker_reminder':
        return 'View booking';
      case 'termination_requested':
        return 'Respond';
      default:
        return 'Open';
    }
  }
}
