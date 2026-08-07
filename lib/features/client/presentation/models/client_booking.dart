import 'client_job_draft.dart';

/// Booking lifecycle statuses aligned with backend_integration.md.
enum ClientBookingStatus {
  draft,
  requested,
  awaitingPayment,
  accepted,
  inProgress,
  pendingApproval,
  completed,
  cancelled,
}

extension ClientBookingStatusX on ClientBookingStatus {
  String get displayLabel {
    switch (this) {
      case ClientBookingStatus.draft:
        return 'Draft';
      case ClientBookingStatus.requested:
        return 'Requested';
      case ClientBookingStatus.awaitingPayment:
        return 'Awaiting Payment';
      case ClientBookingStatus.accepted:
        return 'Accepted';
      case ClientBookingStatus.inProgress:
        return 'In Progress';
      case ClientBookingStatus.pendingApproval:
        return 'Pending Approval';
      case ClientBookingStatus.completed:
        return 'Completed';
      case ClientBookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  static ClientBookingStatus? fromDisplayLabel(String label) {
    for (final status in ClientBookingStatus.values) {
      if (status.displayLabel == label) return status;
    }
    return null;
  }
}

class ClientBooking {
  const ClientBooking({
    required this.id,
    this.jobUuid,
    required this.title,
    required this.artisan,
    required this.profession,
    required this.status,
    required this.date,
    required this.amount,
    this.rating,
    this.imageUrl,
    this.conversationId,
    this.counterpartUserId,
    this.backendStatus,
    this.workerId,
    this.workerIsVerified = false,
    this.locationLat,
    this.locationLng,
    this.phone,
    this.cancelledBy,
    this.cancelledReason,
    this.cancelledAt,
    this.cancellationStage,
    this.cancellationFee,
    this.cancellationFeeCurrency,
    this.jobMode,
    this.scheduledFor,
    this.workEndedAt,
    this.isLocalDraft = false,
    this.draftData,
    this.draftSavedAt,
    this.baseRate,
    this.distanceCost,
    this.urgencyPremium,
    this.grossAmount,
    this.platformFee,
    this.artisanPayout,
  });

  final String id;
  final String? jobUuid;
  final String title;
  final String artisan;
  final String profession;
  final ClientBookingStatus status;
  final String date;
  final String amount;
  final double? rating;
  final String? imageUrl;
  final String? conversationId;
  final String? counterpartUserId;
  final String? backendStatus;
  final String? workerId;
  final bool workerIsVerified;
  final double? locationLat;
  final double? locationLng;
  final String? phone;
  final String? cancelledBy;
  final String? cancelledReason;
  final String? cancelledAt;
  final String? cancellationStage;
  final double? cancellationFee;
  final String? cancellationFeeCurrency;
  final String? jobMode;
  final String? scheduledFor;
  final String? workEndedAt;
  final bool isLocalDraft;
  final Map<String, dynamic>? draftData;
  final String? draftSavedAt;

  // Settlement details
  final double? baseRate;
  final double? distanceCost;
  final double? urgencyPremium;
  final double? grossAmount;
  final double? platformFee;
  final double? artisanPayout;

  bool get canRate =>
      (status == ClientBookingStatus.pendingApproval ||
          status == ClientBookingStatus.completed) &&
      rating == null;

  /// Whether this job can be cancelled by the client from the tracking screen
  bool get isClientCancellable =>
      backendStatus == 'matched' ||
      backendStatus == 'scheduled_confirmed' ||
      backendStatus == 'on_the_way' ||
      backendStatus == 'arrived';

  /// Whether this job allows termination requests
  bool get isTerminationRequestable => backendStatus == 'in_progress';

  bool get isRecoverableServiceInterruption {
    final String raw = (backendStatus ?? '').toLowerCase();
    final String by = (cancelledBy ?? '').toLowerCase();
    final String stage = (cancellationStage ?? '').toLowerCase();
    return raw == 'cancelled' &&
        (by == 'worker' || stage == 'termination_requested');
  }

  bool get isTrackable {
    final String raw = (backendStatus ?? '').toLowerCase();
    return raw == 'awaiting_payment' ||
        raw == 'matched' ||
        raw == 'scheduled_confirmed' ||
        raw == 'on_the_way' ||
        raw == 'arrived' ||
        raw == 'in_progress' ||
        raw == 'pending_client_approval' ||
        raw == 'termination_requested' ||
        isRecoverableServiceInterruption;
  }

  bool get isNavigable =>
      status == ClientBookingStatus.inProgress ||
      status == ClientBookingStatus.pendingApproval ||
      status == ClientBookingStatus.draft ||
      status == ClientBookingStatus.requested ||
      status == ClientBookingStatus.accepted ||
      isRecoverableServiceInterruption ||
      canRate;

  Map<String, dynamic> toMap() => toTrackingMap();

  Map<String, dynamic> toTrackingMap() => {
        'id': id,
        'jobId': jobUuid ?? id,
        'job_id': jobUuid,
        'title': title,
        'artisan': artisan,
        'profession': profession,
        'status': backendStatus ?? status.displayLabel,
        'date': date,
        'amount': amount,
        'rating': rating,
        'client_review_rating': rating,
        'imageUrl': imageUrl,
        'conversationId': jobUuid ?? conversationId,
        'counterpartUserId': workerId ?? counterpartUserId,
        'worker_id': workerId,
        'worker_is_verified': workerIsVerified,
        'location_lat': locationLat,
        'location_lng': locationLng,
        'phone': phone,
        'cancelled_by': cancelledBy,
        'cancelled_reason': cancelledReason,
        'cancelled_at': cancelledAt,
        'cancellation_stage': cancellationStage,
        'cancellation_fee': cancellationFee,
        'cancellation_fee_currency': cancellationFeeCurrency,
        'job_mode': jobMode,
        'scheduled_for': scheduledFor,
        'work_ended_at': workEndedAt,
        'isLocalDraft': isLocalDraft,
        'draftData': draftData,
        'draftSavedAt': draftSavedAt,
        'eta': 'Calculating ETA…',
        'base_rate': baseRate,
        'distance_cost': distanceCost,
        'urgency_premium': urgencyPremium,
        'gross_amount': grossAmount,
        'platform_fee': platformFee,
        'artisan_payout': artisanPayout,
      };

  static ClientBooking fromMap(Map<String, dynamic> map) {
    final status = ClientBookingStatusX.fromDisplayLabel(
          map['status'] as String? ?? '',
        ) ??
        ClientBookingStatus.requested;
    return ClientBooking(
      id: map['id']?.toString() ?? '',
      jobUuid: map['job_id'] as String? ?? map['jobId'] as String?,
      title: map['title'] as String? ?? '',
      artisan: map['artisan'] as String? ?? 'Artisan',
      profession: map['profession'] as String? ?? '',
      status: status,
      date: map['date'] as String? ?? '',
      amount: map['amount'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble(),
      imageUrl: map['imageUrl'] as String?,
      conversationId: map['conversationId'] as String?,
      counterpartUserId: map['counterpartUserId'] as String?,
      backendStatus: map['status'] as String?,
      workerId: map['worker_id'] as String?,
      workerIsVerified: map['worker_is_verified'] == true ||
          map['isVerified'] == true ||
          map['verified'] == true,
      locationLat: (map['location_lat'] as num?)?.toDouble(),
      locationLng: (map['location_lng'] as num?)?.toDouble(),
      phone: map['phone'] as String?,
      cancelledBy: map['cancelled_by'] as String?,
      cancelledReason: map['cancelled_reason'] as String?,
      cancelledAt: map['cancelled_at'] as String?,
      cancellationStage: map['cancellation_stage'] as String?,
      cancellationFee: (map['cancellation_fee'] as num?)?.toDouble(),
      cancellationFeeCurrency: map['cancellation_fee_currency'] as String?,
      jobMode: map['job_mode'] as String?,
      scheduledFor: map['scheduled_for'] as String?,
      isLocalDraft: map['isLocalDraft'] == true,
      draftData: map['draftData'] is Map
          ? Map<String, dynamic>.from(map['draftData'] as Map)
          : null,
      draftSavedAt: map['draftSavedAt'] as String?,
      baseRate: (map['base_rate'] as num?)?.toDouble(),
      distanceCost: (map['distance_cost'] as num?)?.toDouble(),
      urgencyPremium: (map['urgency_premium'] as num?)?.toDouble(),
      grossAmount: (map['gross_amount'] as num?)?.toDouble(),
      platformFee: (map['platform_fee'] as num?)?.toDouble(),
      artisanPayout: (map['artisan_payout'] as num?)?.toDouble(),
    );
  }

  static ClientBooking fromLocalDraft({
    required String draftId,
    required Map<String, dynamic> draftData,
  }) {
    final draft = ClientJobDraft.fromMap(draftData);
    final String? savedAt = draftData['savedAt'] as String?;
    final String date = savedAt?.split('T').first ?? 'Saved locally';
    return ClientBooking(
      id: draftId,
      title: draft.displayTitle,
      artisan: 'Not posted yet',
      profession: draft.displayCategory,
      status: ClientBookingStatus.draft,
      date: date,
      amount: 'GHS ${draft.totalFee.toStringAsFixed(0)}',
      backendStatus: 'draft',
      jobMode: draft.urgency,
      scheduledFor: draft.preferredDate?.toUtc().toIso8601String(),
      isLocalDraft: true,
      draftData: Map<String, dynamic>.from(draftData),
      draftSavedAt: savedAt,
      locationLat: draft.locationLat,
      locationLng: draft.locationLng,
    );
  }

  static ClientBooking fromApiJob(Map<String, dynamic> json) {
    final String statusRaw = (json['status'] as String? ?? '').toLowerCase();
    final String jobMode = (json['job_mode'] as String? ?? '').toLowerCase();
    final ClientBookingStatus status = switch (statusRaw) {
      'awaiting_payment' => ClientBookingStatus.awaitingPayment,
      'matched' => ClientBookingStatus.accepted,
      // Worker confirmed for a future scheduled slot; activates near the time.
      'scheduled_confirmed' => ClientBookingStatus.accepted,
      'on_the_way' => ClientBookingStatus.accepted,
      'arrived' => ClientBookingStatus.accepted,
      'in_progress' => ClientBookingStatus.inProgress,
      'termination_requested' => ClientBookingStatus.inProgress,
      'pending_client_approval' => ClientBookingStatus.pendingApproval,
      'completed' => ClientBookingStatus.completed,
      'cancelled' || 'expired' => ClientBookingStatus.cancelled,
      'draft' when jobMode == 'scheduled' => ClientBookingStatus.requested,
      _ => ClientBookingStatus.requested,
    };
    final dynamic worker =
        json['worker'] ?? json['requested_worker'] ?? json['profiles'];
    final String artisanName = worker is Map<String, dynamic>
        ? worker['full_name'] as String? ?? 'Artisan'
        : 'Artisan';
    final dynamic category = json['categories'];
    final String categoryName = category is Map<String, dynamic>
        ? (category['name'] as String? ?? 'Artisan')
        : 'Artisan';
    final String profession = worker is Map<String, dynamic>
        ? (worker['profession'] as String? ?? categoryName)
        : categoryName;
    final String? phone =
        worker is Map<String, dynamic> ? worker['phone'] as String? : null;
    final bool workerIsVerified =
        worker is Map<String, dynamic> && worker['is_verified'] == true;
    final String? jobId = json['id'] as String?;

    final dynamic completionRaw = json['completion_details'];
    Map<String, dynamic> completion = <String, dynamic>{};
    if (completionRaw is List &&
        completionRaw.isNotEmpty &&
        completionRaw.first is Map) {
      completion = Map<String, dynamic>.from(completionRaw.first as Map);
    } else if (completionRaw is Map) {
      completion = Map<String, dynamic>.from(completionRaw);
    }

    return ClientBooking(
      id: jobId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Job',
      artisan: artisanName,
      profession: profession,
      status: status,
      date: json['created_at']?.toString().split('T').first ?? '',
      amount: 'GHS ${json['budget_min'] ?? json['budget_fixed'] ?? '—'}',
      rating: (json['client_review_rating'] as num?)?.toDouble(),
      imageUrl: worker is Map<String, dynamic>
          ? worker['avatar_url'] as String?
          : null,
      counterpartUserId: json['worker_id'] as String? ??
          json['requested_worker_id'] as String?,
      jobUuid: jobId,
      conversationId: jobId,
      backendStatus: statusRaw,
      workerId: json['worker_id'] as String?,
      workerIsVerified: workerIsVerified,
      locationLat: (json['location_lat'] as num?)?.toDouble(),
      locationLng: (json['location_lng'] as num?)?.toDouble(),
      phone: phone,
      cancelledBy: json['cancelled_by'] as String?,
      cancelledReason: json['cancelled_reason'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
      cancellationStage: json['cancellation_stage'] as String?,
      cancellationFee: (json['cancellation_fee'] as num?)?.toDouble(),
      cancellationFeeCurrency: json['cancellation_fee_currency'] as String?,
      jobMode: json['job_mode'] as String?,
      scheduledFor: json['scheduled_for'] as String?,
      workEndedAt: json['work_ended_at'] as String?,
      baseRate: (completion['base_rate'] as num?)?.toDouble(),
      distanceCost: (completion['distance_cost'] as num?)?.toDouble(),
      urgencyPremium: (completion['urgency_premium'] as num?)?.toDouble(),
      grossAmount: (completion['gross_amount'] as num?)?.toDouble(),
      platformFee: (completion['platform_fee'] as num?)?.toDouble(),
      artisanPayout: (completion['artisan_payout'] as num?)?.toDouble(),
    );
  }

  /// First matched or in-progress job from API list.
  static ClientBooking? pickActiveTrackable(
      Iterable<Map<String, dynamic>> jobs) {
    for (final Map<String, dynamic> json in jobs) {
      final String statusRaw = (json['status'] as String? ?? '').toLowerCase();
      if (statusRaw == 'awaiting_payment' ||
          statusRaw == 'matched' ||
          statusRaw == 'scheduled_confirmed' ||
          statusRaw == 'on_the_way' ||
          statusRaw == 'arrived' ||
          statusRaw == 'in_progress' ||
          statusRaw == 'termination_requested' ||
          statusRaw == 'pending_client_approval' ||
          (statusRaw == 'cancelled' &&
              (((json['cancelled_by'] as String?) ?? '').toLowerCase() ==
                      'worker' ||
                  (((json['cancellation_stage'] as String?) ?? '')
                          .toLowerCase() ==
                      'termination_requested')))) {
        return ClientBooking.fromApiJob(json);
      }
    }
    return null;
  }

  /// Tracking payload created after posting a job or hiring from profile.
  static Map<String, dynamic> fromJobPost({
    required Map<String, dynamic> jobData,
    Map<String, dynamic>? artisan,
  }) {
    final draft = ClientJobDraft.fromMap(jobData);
    final artisanName = artisan?['name'] as String? ?? 'Artisan';
    final profession =
        artisan?['profession'] as String? ?? draft.displayCategory;
    final String? jobId = jobData['id'] as String?;
    final map = ClientBooking(
      id: jobId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      jobUuid: jobId,
      title: draft.displayTitle,
      artisan: artisanName,
      profession: profession,
      status: ClientBookingStatus.inProgress,
      date: 'Today',
      amount: 'GHS ${draft.budgetMax.toStringAsFixed(0)}',
      imageUrl: artisan?['imageUrl'] as String?,
      conversationId: jobId,
      counterpartUserId: jobData['worker_id'] as String?,
      backendStatus: (jobData['status'] as String?) ?? 'matched',
      workerId: jobData['worker_id'] as String?,
      workerIsVerified: artisan?['is_verified'] == true ||
          artisan?['isVerified'] == true ||
          artisan?['verified'] == true,
      locationLat: (jobData['locationLat'] as num?)?.toDouble() ??
          (jobData['location_lat'] as num?)?.toDouble(),
      locationLng: (jobData['locationLng'] as num?)?.toDouble() ??
          (jobData['location_lng'] as num?)?.toDouble(),
    ).toTrackingMap();
    return map;
  }
}
