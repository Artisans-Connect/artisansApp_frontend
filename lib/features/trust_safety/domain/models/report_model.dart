import 'report_category.dart';

class SafetyReport {
  final String id;
  final String ticketNumber;
  final String categoryKey;
  final String description;
  final List<String> attachments;
  final String priority;
  final String status;
  final bool isEmergency;
  final String actionTaken;
  final String? resolutionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  const SafetyReport({
    required this.id,
    required this.ticketNumber,
    required this.categoryKey,
    required this.description,
    required this.attachments,
    required this.priority,
    required this.status,
    required this.isEmergency,
    required this.actionTaken,
    this.resolutionReason,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  ReportCategory get category => ReportCategory.fromKey(categoryKey);

  factory SafetyReport.fromJson(Map<String, dynamic> json) {
    return SafetyReport(
      id: json['id'] as String? ?? '',
      ticketNumber: json['ticket_number'] as String? ?? '',
      categoryKey: json['category'] as String? ?? 'OTHER',
      description: json['description'] as String? ?? '',
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      priority: json['priority'] as String? ?? 'MEDIUM',
      status: json['status'] as String? ?? 'PENDING',
      isEmergency: json['is_emergency'] as bool? ?? false,
      actionTaken: json['action_taken'] as String? ?? 'NONE',
      resolutionReason: json['resolution_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }
}
