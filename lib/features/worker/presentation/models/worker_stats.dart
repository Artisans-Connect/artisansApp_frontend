class WorkerStats {
  const WorkerStats({
    required this.totalJobs,
    required this.rating,
    required this.reviewCount,
    required this.responseLabel,
    required this.responseSampleCount,
    required this.recentReviews,
  });

  final int totalJobs;
  final double rating;
  final int reviewCount;
  final String responseLabel;
  final int responseSampleCount;
  final List<WorkerReviewSummary> recentReviews;

  factory WorkerStats.fromMap(Map<String, dynamic> map) {
    return WorkerStats(
      totalJobs: (map['total_jobs'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
      responseLabel: map['response_hours_label'] as String? ?? '--',
      responseSampleCount: (map['response_sample_count'] as num?)?.toInt() ?? 0,
      recentReviews: (map['recent_reviews'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((Map<dynamic, dynamic> item) =>
              WorkerReviewSummary.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class WorkerReviewSummary {
  const WorkerReviewSummary({
    required this.id,
    required this.rating,
    required this.reviewerName,
    this.comment,
    this.createdAt,
  });

  final String id;
  final double rating;
  final String reviewerName;
  final String? comment;
  final DateTime? createdAt;

  factory WorkerReviewSummary.fromMap(Map<String, dynamic> map) {
    return WorkerReviewSummary(
      id: map['id']?.toString() ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewerName: map['reviewer_name'] as String? ?? 'Client',
      comment: map['comment'] as String?,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
    );
  }
}
