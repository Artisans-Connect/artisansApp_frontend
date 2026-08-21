import 'package:artisans_app/shared/models/worker_job.dart';

JobUrgency _urgencyFromJobMode(dynamic jobMode) {
  return (jobMode?.toString().toLowerCase() ?? '') == 'asap'
      ? JobUrgency.asap
      : JobUrgency.scheduled;
}

String? _scheduledLabelFor(Map<String, dynamic> json) {
  final String? scheduledFor = json['scheduled_for'] as String?;
  if (scheduledFor == null) return null;
  final DateTime? when = DateTime.tryParse(scheduledFor)?.toLocal();
  if (when == null) return null;
  final String hour = when.hour.toString().padLeft(2, '0');
  final String minute = when.minute.toString().padLeft(2, '0');
  return 'Scheduled ${when.day}/${when.month} $hour:$minute';
}

WorkerJob workerJobFromApi(Map<String, dynamic> json) {
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
  final String? categoryIconName =
      category is Map<String, dynamic> ? category['icon_name'] as String? : null;
  final String? categoryColorHex =
      category is Map<String, dynamic> ? category['color_hex'] as String? : null;
  final List<String> photoUrls =
      (json['photo_urls'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic url) => url.toString())
          .toList();

  final Map<String, dynamic> completion =
      _firstRelated(json['completion_details']);
  final Map<String, dynamic> applicationQuote =
      _firstRelated(json['application_quote']);
  final List<String> completionPhotoUrls =
      (completion['photo_urls'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic url) => url.toString())
          .toList();

  return WorkerJob(
    id: json['id'] as String,
    title: json['title'] as String? ?? 'Job request',
    category: categoryName,
    categoryIconName: categoryIconName,
    categoryColorHex: categoryColorHex,
    description: json['description'] as String? ?? '',
    addressLabel: json['address_label'] as String? ?? 'Unknown',
    latitude: (json['location_lat'] as num?)?.toDouble() ?? 0,
    longitude: (json['location_lng'] as num?)?.toDouble() ?? 0,
    clientName: clientName,
    clientId: json['client_id'] as String?,
    clientPhone: clientPhone,
    clientAvatarUrl: clientAvatarUrl,
    urgency: _urgencyFromJobMode(json['job_mode']),
    scheduledLabel: _scheduledLabelFor(json),
    estimatedBudgetLabel: _budgetLabel(json),
    referencePhotoLabels: photoUrls,
    photoCount: photoUrls.length,
    backendStatus: json['status'] as String?,
    distanceKm: (applicationQuote['distance_km'] as num?)?.toDouble(),
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    trade: categoryName,
    area: json['address_label'] as String?,
    startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'].toString()) : null,
    completionHours: (completion['hours_spent'] as num?)?.toDouble(),
    completionMaterials: completion['materials_used'] as String?,
    completionNotes: completion['notes'] as String?,
    completionPhotoUrls: completionPhotoUrls,
    baseRate: (completion['base_rate'] as num?)?.toDouble(),
    distanceCost: (completion['distance_cost'] as num?)?.toDouble(),
    urgencyPremium: (completion['urgency_premium'] as num?)?.toDouble(),
    grossAmount: (completion['gross_amount'] as num?)?.toDouble(),
    platformFee: (completion['platform_fee'] as num?)?.toDouble(),
    artisanPayout: (completion['artisan_payout'] as num?)?.toDouble(),
    earnedAmount: (completion['artisan_payout'] as num?)?.toDouble() ??
        (completion['gross_amount'] as num?)?.toDouble(),
    applicationDistanceKm:
        (applicationQuote['distance_km'] as num?)?.toDouble(),
    applicationDistanceCost:
        (applicationQuote['distance_cost'] as num?)?.toDouble(),
    applicationBaseServiceFee:
        (applicationQuote['base_service_fee'] as num?)?.toDouble(),
    applicationUrgencyPremium:
        (applicationQuote['urgency_premium'] as num?)?.toDouble(),
    applicationTotalQuote:
        (applicationQuote['total_quote'] as num?)?.toDouble(),
    applicationQuoteCurrency: applicationQuote['quote_currency'] as String?,
  );
}

WorkerJob workerHistoryJobFromApi(Map<String, dynamic> json) {
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
  final String? categoryIconName =
      category is Map<String, dynamic> ? category['icon_name'] as String? : null;
  final String? categoryColorHex =
      category is Map<String, dynamic> ? category['color_hex'] as String? : null;
  final String status = (json['status'] as String? ?? '').toLowerCase();
  final Map<String, dynamic> completion =
      _firstRelated(json['completion_details']);
  final List<String> completionPhotoUrls =
      (completion['photo_urls'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic url) => url.toString())
          .toList();

  return WorkerJob(
    id: json['id'] as String,
    title: json['title'] as String? ?? 'Job',
    category: categoryName,
    categoryIconName: categoryIconName,
    categoryColorHex: categoryColorHex,
    description: '',
    addressLabel: json['address_label'] as String? ?? 'Unknown',
    latitude: 0,
    longitude: 0,
    clientName: clientName,
    clientId: json['client_id'] as String?,
    clientPhone: clientPhone,
    clientAvatarUrl: clientAvatarUrl,
    urgency: JobUrgency.scheduled,
    estimatedBudgetLabel: _budgetLabel(json),
    backendStatus: status,
    distanceKm: null,
    historyDate: json['updated_at']?.toString().split('T').first ?? 'Just now',
    historyStatus: status == 'completed'
        ? HistoryStatus.completed
        : HistoryStatus.cancelled,
    completionHours: (completion['hours_spent'] as num?)?.toDouble(),
    completionMaterials: completion['materials_used'] as String?,
    completionNotes: completion['notes'] as String?,
    completionPhotoUrls: completionPhotoUrls,
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    trade: categoryName,
    area: json['address_label'] as String?,
    startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'].toString()) : null,
    baseRate: (completion['base_rate'] as num?)?.toDouble(),
    distanceCost: (completion['distance_cost'] as num?)?.toDouble(),
    urgencyPremium: (completion['urgency_premium'] as num?)?.toDouble(),
    grossAmount: (completion['gross_amount'] as num?)?.toDouble(),
    platformFee: (completion['platform_fee'] as num?)?.toDouble(),
    artisanPayout: (completion['artisan_payout'] as num?)?.toDouble(),
    earnedAmount: (completion['artisan_payout'] as num?)?.toDouble() ??
        (completion['gross_amount'] as num?)?.toDouble(),
  );
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
