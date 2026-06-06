class JobReceiptViewData {
  const JobReceiptViewData({
    required this.jobId,
    required this.title,
    required this.clientName,
    required this.location,
    required this.completedAt,
    required this.amountGhs,
    required this.status,
    this.hoursSpent,
    this.notes,
    this.photoUrls = const <String>[],
  });

  final String jobId;
  final String title;
  final String clientName;
  final String location;
  final DateTime completedAt;
  final double amountGhs;
  final String status;
  final double? hoursSpent;
  final String? notes;
  final List<String> photoUrls;

  factory JobReceiptViewData.fromJson(Map<String, dynamic> json) {
    final clientProfile =
        json['client'] as Map<String, dynamic>? ??
        json['client_profile'] as Map<String, dynamic>?;
    final completion = _firstRelated(json['completion_details']);
    return JobReceiptViewData(
      jobId: json['id'] as String,
      title: json['title'] as String? ?? 'Job receipt',
      clientName: clientProfile?['full_name'] as String? ?? 'Unknown Client',
      location: json['address_label'] as String? ??
          json['location_address'] as String? ??
          'Unknown Location',
      completedAt: DateTime.tryParse(
            json['completed_at']?.toString() ??
                json['updated_at']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      amountGhs: (json['budget_fixed'] as num?)?.toDouble() ??
          (json['budget_min'] as num?)?.toDouble() ??
          (json['budget'] as num?)?.toDouble() ??
          0.0,
      status: _statusLabel(json['status'] as String? ?? 'completed'),
      hoursSpent: (completion['hours_spent'] as num?)?.toDouble(),
      notes: _firstNonBlank(
        completion['notes'] as String?,
        json['description'] as String?,
      ),
      photoUrls: (completion['photo_urls'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': jobId,
      'title': title,
      'status': status,
      'budget': amountGhs,
      'hours_spent': hoursSpent,
      'description': notes,
      'photo_urls': photoUrls,
      'location_address': location,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}

String? _firstNonBlank(String? first, String? second) {
  if (first != null && first.trim().isNotEmpty) return first.trim();
  if (second != null && second.trim().isNotEmpty) return second.trim();
  return null;
}

String _statusLabel(String raw) {
  return raw
      .split('_')
      .where((String part) => part.isNotEmpty)
      .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

Map<String, dynamic> _firstRelated(dynamic value) {
  if (value is List && value.isNotEmpty && value.first is Map) {
    return Map<String, dynamic>.from(value.first as Map);
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}
