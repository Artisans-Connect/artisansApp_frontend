class JobRouteArgs {
  const JobRouteArgs({required this.jobId, this.snapshot});
  final String jobId;
  final Map<String, dynamic>? snapshot;
  static JobRouteArgs? tryParse(Object? value) {
    if (value is JobRouteArgs) return value;
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final id = (map['job_id'] ?? map['jobId'] ?? map['id'] ?? '').toString();
      return id.isEmpty ? null : JobRouteArgs(jobId: id, snapshot: map);
    }
    if (value is String && value.isNotEmpty) return JobRouteArgs(jobId: value);
    return null;
  }
  Map<String, dynamic> toMap() => <String, dynamic>{...?snapshot, 'id': jobId, 'job_id': jobId};
}

class ArtisanRouteArgs {
  const ArtisanRouteArgs({required this.userId, this.snapshot});
  final String userId;
  final Map<String, dynamic>? snapshot;
  static ArtisanRouteArgs? tryParse(Object? value) {
    if (value is ArtisanRouteArgs) return value;
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final id = (map['userId'] ?? map['user_id'] ?? map['worker_id'] ?? map['id'] ?? '').toString();
      return id.isEmpty ? null : ArtisanRouteArgs(userId: id, snapshot: map);
    }
    if (value is String && value.isNotEmpty) return ArtisanRouteArgs(userId: value);
    return null;
  }
}
