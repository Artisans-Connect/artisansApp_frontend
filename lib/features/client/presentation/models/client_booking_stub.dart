import 'client_job_draft.dart';

/// Booking lifecycle statuses aligned with backend_integration.md.
enum ClientBookingStatus {
  requested,
  accepted,
  inProgress,
  completed,
  cancelled,
}

extension ClientBookingStatusX on ClientBookingStatus {
  String get displayLabel {
    switch (this) {
      case ClientBookingStatus.requested:
        return 'Requested';
      case ClientBookingStatus.accepted:
        return 'Accepted';
      case ClientBookingStatus.inProgress:
        return 'In Progress';
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
    this.jobUuid,
    this.backendStatus,
    this.workerId,
    this.locationLat,
    this.locationLng,
    this.phone,
  });

  final int id;
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
  final double? locationLat;
  final double? locationLng;
  final String? phone;

  bool get canRate =>
      status == ClientBookingStatus.completed && rating == null;

  bool get isTrackable {
    final String raw = (backendStatus ?? '').toLowerCase();
    return raw == 'matched' || raw == 'in_progress';
  }

  bool get isNavigable =>
      status == ClientBookingStatus.inProgress ||
      status == ClientBookingStatus.requested ||
      status == ClientBookingStatus.accepted ||
      canRate;

  Map<String, dynamic> toMap() => toTrackingMap();

  Map<String, dynamic> toTrackingMap() => {
        'id': jobUuid ?? id.toString(),
        'jobId': jobUuid ?? id.toString(),
        'job_id': jobUuid,
        'title': title,
        'artisan': artisan,
        'profession': profession,
        'status': backendStatus ?? status.displayLabel,
        'date': date,
        'amount': amount,
        'rating': rating,
        'imageUrl': imageUrl,
        'conversationId': jobUuid ?? conversationId,
        'counterpartUserId': workerId ?? counterpartUserId,
        'worker_id': workerId,
        'location_lat': locationLat,
        'location_lng': locationLng,
        'phone': phone,
        'eta': 'Calculating ETA…',
      };

  static ClientBooking fromMap(Map<String, dynamic> map) {
    final status = ClientBookingStatusX.fromDisplayLabel(
          map['status'] as String? ?? '',
        ) ??
        ClientBookingStatus.requested;
    return ClientBooking(
      id: map['id'] is int ? map['id'] as int : 0,
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
      locationLat: (map['location_lat'] as num?)?.toDouble(),
      locationLng: (map['location_lng'] as num?)?.toDouble(),
      phone: map['phone'] as String?,
    );
  }

  static ClientBooking fromApiJob(Map<String, dynamic> json) {
    final String statusRaw = (json['status'] as String? ?? '').toLowerCase();
    final ClientBookingStatus status = switch (statusRaw) {
      'matched' => ClientBookingStatus.accepted,
      'in_progress' => ClientBookingStatus.inProgress,
      'completed' => ClientBookingStatus.completed,
      'cancelled' || 'expired' => ClientBookingStatus.cancelled,
      _ => ClientBookingStatus.requested,
    };
    final dynamic worker = json['worker'] ?? json['profiles'];
    final String artisanName = worker is Map<String, dynamic>
        ? worker['full_name'] as String? ?? 'Artisan'
        : 'Artisan';
    final String? phone = worker is Map<String, dynamic>
        ? worker['phone'] as String?
        : null;
    final String? jobId = json['id'] as String?;
    return ClientBooking(
      id: jobId?.hashCode ?? 0,
      title: json['title'] as String? ?? 'Job',
      artisan: artisanName,
      profession: 'Artisan',
      status: status,
      date: json['created_at']?.toString().split('T').first ?? '',
      amount: 'GHS ${json['budget_min'] ?? json['budget_fixed'] ?? '—'}',
      imageUrl: worker is Map<String, dynamic>
          ? worker['avatar_url'] as String?
          : null,
      counterpartUserId: json['worker_id'] as String?,
      jobUuid: jobId,
      conversationId: jobId,
      backendStatus: statusRaw,
      workerId: json['worker_id'] as String?,
      locationLat: (json['location_lat'] as num?)?.toDouble(),
      locationLng: (json['location_lng'] as num?)?.toDouble(),
      phone: phone,
    );
  }

  /// First matched or in-progress job from API list.
  static ClientBooking? pickActiveTrackable(Iterable<Map<String, dynamic>> jobs) {
    for (final Map<String, dynamic> json in jobs) {
      final String statusRaw = (json['status'] as String? ?? '').toLowerCase();
      if (statusRaw == 'matched' || statusRaw == 'in_progress') {
        return ClientBooking.fromApiJob(json);
      }
    }
    return null;
  }

  static List<ClientBooking> get sampleBookings => [
        const ClientBooking(
          id: 1,
          title: 'Fix leaking kitchen faucet',
          artisan: 'John Smith',
          profession: 'Professional Plumber',
          status: ClientBookingStatus.completed,
          date: 'May 18, 2024',
          rating: 4.8,
          amount: '\$150',
          imageUrl: 'https://via.placeholder.com/100?text=John',
          conversationId: 'conv-1',
          counterpartUserId: 'worker-john',
        ),
        const ClientBooking(
          id: 2,
          title: 'Install smart lighting system',
          artisan: 'Sarah Johnson',
          profession: 'Expert Electrician',
          status: ClientBookingStatus.inProgress,
          date: 'May 20, 2024',
          amount: '\$280',
          imageUrl: 'https://via.placeholder.com/100?text=Sarah',
          conversationId: 'conv-2',
          counterpartUserId: 'worker-sarah',
          backendStatus: 'in_progress',
        ),
        const ClientBooking(
          id: 3,
          title: 'Paint bedroom walls',
          artisan: 'Mike Wilson',
          profession: 'Professional Painter',
          status: ClientBookingStatus.cancelled,
          date: 'May 15, 2024',
          amount: '\$200',
          imageUrl: 'https://via.placeholder.com/100?text=Mike',
        ),
        const ClientBooking(
          id: 4,
          title: 'Deep clean house',
          artisan: 'Emma Davis',
          profession: 'Professional Cleaner',
          status: ClientBookingStatus.completed,
          date: 'May 10, 2024',
          amount: '\$120',
          imageUrl: 'https://via.placeholder.com/100?text=Emma',
          conversationId: 'conv-4',
          counterpartUserId: 'worker-emma',
        ),
        const ClientBooking(
          id: 5,
          title: 'Repair bathroom tiles',
          artisan: 'Pending match',
          profession: 'Tiler',
          status: ClientBookingStatus.requested,
          date: 'May 22, 2024',
          amount: '\$90',
          imageUrl: 'https://via.placeholder.com/100?text=Job',
        ),
      ];

  /// Stub booking created after posting a job or hiring from profile.
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
      id: DateTime.now().millisecondsSinceEpoch,
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
      locationLat: (jobData['locationLat'] as num?)?.toDouble() ??
          (jobData['location_lat'] as num?)?.toDouble(),
      locationLng: (jobData['locationLng'] as num?)?.toDouble() ??
          (jobData['location_lng'] as num?)?.toDouble(),
    ).toTrackingMap();
    return map;
  }
}
