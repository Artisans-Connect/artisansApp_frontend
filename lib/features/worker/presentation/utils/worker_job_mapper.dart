import '../models/mock_worker_job.dart';

MockWorkerJob workerJobFromApi(Map<String, dynamic> json) {
  final dynamic client = json['client'] ?? json['profiles'];
  final String clientName = client is Map<String, dynamic>
      ? client['full_name'] as String? ?? 'Client'
      : 'Client';
  final dynamic category = json['categories'];
  final String categoryName = category is Map<String, dynamic>
      ? category['name'] as String? ?? 'General'
      : 'General';

  return MockWorkerJob(
    id: json['id'] as String,
    title: json['title'] as String? ?? 'Job request',
    category: categoryName,
    description: json['description'] as String? ?? '',
    addressLabel: json['address_label'] as String? ?? 'Unknown',
    latitude: (json['location_lat'] as num?)?.toDouble() ?? 0,
    longitude: (json['location_lng'] as num?)?.toDouble() ?? 0,
    clientName: clientName,
    urgency: JobUrgency.scheduled,
    estimatedBudgetLabel:
        '${json['budget_min'] ?? '—'} - ${json['budget_max'] ?? '—'} GHS',
    distanceKm: null,
  );
}

MockWorkerJob workerHistoryJobFromApi(Map<String, dynamic> json) {
  final dynamic client = json['client'] ?? json['profiles'];
  final String clientName = client is Map<String, dynamic>
      ? client['full_name'] as String? ?? 'Client'
      : 'Client';
  final dynamic category = json['categories'];
  final String categoryName = category is Map<String, dynamic>
      ? category['name'] as String? ?? 'General'
      : 'General';
  final String status = (json['status'] as String? ?? '').toLowerCase();

  return MockWorkerJob(
    id: json['id'] as String,
    title: json['title'] as String? ?? 'Job',
    category: categoryName,
    description: '',
    addressLabel: json['address_label'] as String? ?? 'Unknown',
    latitude: 0,
    longitude: 0,
    clientName: clientName,
    urgency: JobUrgency.scheduled,
    estimatedBudgetLabel:
        '${json['budget_min'] ?? '—'} - ${json['budget_max'] ?? '—'} GHS',
    distanceKm: null,
    historyDate: json['updated_at']?.toString().split('T').first ?? 'Just now',
    historyStatus: status == 'completed'
        ? HistoryStatus.completed
        : HistoryStatus.cancelled,
  );
}
