class JobReceiptViewData {
  const JobReceiptViewData({
    required this.jobId,
    required this.title,
    required this.clientName,
    required this.location,
    required this.completedAt,
    required this.amountGhs,
    required this.status,
    this.notes,
  });

  final String jobId;
  final String title;
  final String clientName;
  final String location;
  final DateTime completedAt;
  final double amountGhs;
  final String status;
  final String? notes;

  factory JobReceiptViewData.fromJson(Map<String, dynamic> json) {
    final clientProfile =
        json['client'] as Map<String, dynamic>? ??
        json['client_profile'] as Map<String, dynamic>?;
    return JobReceiptViewData(
      jobId: json['id'] as String,
      title: json['title'] as String? ?? 'Job receipt',
      clientName: clientProfile?['full_name'] as String? ?? 'Unknown Client',
      location: json['address_label'] as String? ??
          json['location_address'] as String? ??
          'Unknown Location',
      completedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : DateTime.now(),
      amountGhs: (json['budget_fixed'] as num?)?.toDouble() ??
          (json['budget_min'] as num?)?.toDouble() ??
          (json['budget'] as num?)?.toDouble() ??
          0.0,
      status: (json['status'] as String? ?? 'completed').toUpperCase(),
      notes: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': jobId,
      'title': title,
      'status': status,
      'budget': amountGhs,
      'description': notes,
      'location_address': location,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}
