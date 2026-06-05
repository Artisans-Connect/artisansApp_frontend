import '../models/mock_worker_job.dart';

MockWorkerJob workerJobFromApi(Map<String, dynamic> json) {
  final dynamic client = json['client'] ?? json['profiles'];
  final String clientName = client is Map<String, dynamic>
      ? client['full_name'] as String? ?? 'Client'
      : 'Client';
  final String? clientPhone =
      client is Map<String, dynamic> ? client['phone'] as String? : null;
  final String? clientAvatarUrl =
      client is Map<String, dynamic> ? client['avatar_url'] as String? : null;
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
    clientPhone: clientPhone,
    clientAvatarUrl: clientAvatarUrl,
    urgency: JobUrgency.scheduled,
    estimatedBudgetLabel: _budgetLabel(json),
    distanceKm: null,
  );
}

MockWorkerJob workerHistoryJobFromApi(Map<String, dynamic> json) {
  final dynamic client = json['client'] ?? json['profiles'];
  final String clientName = client is Map<String, dynamic>
      ? client['full_name'] as String? ?? 'Client'
      : 'Client';
  final String? clientPhone =
      client is Map<String, dynamic> ? client['phone'] as String? : null;
  final String? clientAvatarUrl =
      client is Map<String, dynamic> ? client['avatar_url'] as String? : null;
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
    clientPhone: clientPhone,
    clientAvatarUrl: clientAvatarUrl,
    urgency: JobUrgency.scheduled,
    estimatedBudgetLabel: _budgetLabel(json),
    distanceKm: null,
    historyDate: json['updated_at']?.toString().split('T').first ?? 'Just now',
    historyStatus: status == 'completed'
        ? HistoryStatus.completed
        : HistoryStatus.cancelled,
  );
}

String _budgetLabel(Map<String, dynamic> json) {
  final String budgetType = (json['budget_type'] as String? ?? '').toLowerCase();
  final num? fixed = json['budget_fixed'] as num?;
  final num? min = json['budget_min'] as num?;
  final num? max = json['budget_max'] as num?;

  if (budgetType == 'fixed' && fixed != null) {
    return '${_formatMoney(fixed)} GHS';
  }
  if (min != null && max != null) {
    if (min == max) return '${_formatMoney(min)} GHS';
    return '${_formatMoney(min)} - ${_formatMoney(max)} GHS';
  }
  if (min != null) return 'From ${_formatMoney(min)} GHS';
  if (max != null) return 'Up to ${_formatMoney(max)} GHS';
  if (fixed != null) return '${_formatMoney(fixed)} GHS';
  return 'Budget not set';
}

String _formatMoney(num value) {
  final double amount = value.toDouble();
  if (amount == amount.roundToDouble()) {
    return amount.toInt().toString();
  }
  return amount.toStringAsFixed(2);
}
