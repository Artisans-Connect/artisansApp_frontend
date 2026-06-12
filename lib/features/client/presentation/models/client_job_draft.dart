import 'job_post_wizard_step.dart';

/// In-memory job post draft passed through the client job wizard.
class ClientJobDraft {
  ClientJobDraft([Map<String, dynamic>? initial])
      : data = Map<String, dynamic>.from(initial ?? {});

  final Map<String, dynamic> data;

  factory ClientJobDraft.fromMap(Map<String, dynamic>? map) =>
      ClientJobDraft(map);

  static ClientJobDraft fromArguments(Object? args) {
    if (args is ClientJobDraft) return args;
    if (args is Map<String, dynamic>) return ClientJobDraft.fromMap(args);
    return ClientJobDraft();
  }

  Map<String, dynamic> toMap() => Map<String, dynamic>.from(data);

  void merge(Map<String, dynamic> patch) => data.addAll(patch);

  String? get categoryId =>
      data['categoryId'] as String? ?? data['category'] as String?;

  String? get categoryName => data['categoryName'] as String?;

  String? get categorySlug =>
      data['categorySlug'] as String? ??
      data['category_slug'] as String? ??
      data['categoryKey'] as String?;

  String? get subcategoryId =>
      data['subcategoryId'] as String? ?? data['subcategory'] as String?;

  String? get subcategoryName => data['subcategoryName'] as String?;

  String? get title => data['title'] as String?;

  String? get description => data['description'] as String?;

  String? get address => data['address'] as String?;

  double? get locationLat => (data['locationLat'] as num?)?.toDouble();

  double? get locationLng => (data['locationLng'] as num?)?.toDouble();

  bool get hasUsableLocation => locationLat != null && locationLng != null;

  String? get urgency => data['urgency'] as String?;

  String? get timeWindow => data['timeWindow'] as String?;

  DateTime? get preferredDate {
    final Object? raw = data['preferredDate'];
    if (raw is DateTime) return raw;
    return null;
  }

  double get recommendedFee {
    final value = data['recommendedFee'];
    if (value is num) return value.toDouble();
    return 0;
  }

  double get clientPremium {
    final value = data['clientPremium'];
    if (value is num) return value.toDouble();
    return 0;
  }

  double get totalFee => recommendedFee + clientPremium;

  double get budgetMin => totalFee > 0 ? totalFee : 50;

  double get budgetMax => totalFee > 0 ? totalFee : 50;

  List<String> get photoUrls {
    final Object? raw = data['photoUrls'];
    if (raw is List) return raw.cast<String>();
    return <String>[];
  }

  String get displayTitle =>
      title?.trim().isNotEmpty == true ? title!.trim() : 'Untitled job request';

  String get displayDescription => description?.trim().isNotEmpty == true
      ? description!.trim()
      : 'No description provided.';

  String get displayCategory =>
      categoryName?.trim().isNotEmpty == true
          ? categoryName!.trim()
          : _humanizeId(categoryId) ?? 'General';

  String get displaySubcategory =>
      subcategoryName?.trim().isNotEmpty == true
          ? subcategoryName!.trim()
          : _humanizeId(subcategoryId) ?? '';

  String get displayLocation =>
      address?.trim().isNotEmpty == true ? address!.trim() : 'Location TBD';

  String get displayUrgency {
    switch (urgency) {
      case 'asap':
        return 'As soon as possible';
      case 'scheduled':
        return 'Scheduled';
      default:
        return urgency ?? 'Standard';
    }
  }

  bool get hasAnyData =>
      categoryId != null ||
      title?.isNotEmpty == true ||
      description?.isNotEmpty == true;

  bool isValidForStep(JobPostWizardStep step) {
    switch (step) {
      case JobPostWizardStep.category:
        return categoryId != null && categoryId!.isNotEmpty;
      case JobPostWizardStep.subcategory:
        return subcategoryId != null && subcategoryId!.isNotEmpty;
      case JobPostWizardStep.details:
        return (title != null && title!.trim().length >= 3) &&
            (description != null && description!.trim().length >= 20);
      case JobPostWizardStep.locationSchedule:
        return address != null && address!.trim().isNotEmpty && hasUsableLocation;
      case JobPostWizardStep.summary:
        return isValidForStep(JobPostWizardStep.details) &&
            isValidForStep(JobPostWizardStep.locationSchedule);
    }
  }

  static String? _humanizeId(String? id) {
    if (id == null || id.isEmpty) return null;
    return id
        .split('_')
        .map((String w) =>
            w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static String formatGhs(double amount) => 'GH₵${amount.toStringAsFixed(0)}';

  /// Maps wizard draft fields to the Express `POST /jobs/create` body.
  Map<String, dynamic> toCreateJobPayload() {
    final double? lat = locationLat;
    final double? lng = locationLng;
    if (lat == null || lng == null) {
      throw StateError('Select the job location on the map before posting.');
    }

    final String urgencyValue = (urgency ?? 'asap').toLowerCase();
    final String jobMode = switch (urgencyValue) {
      'scheduled' => 'scheduled',
      'flexible' => 'flexible',
      _ => 'asap',
    };

    final double fee = totalFee >= 50 ? totalFee : 50;

    final Map<String, dynamic> payload = <String, dynamic>{
      'category_id': categoryId,
      'title': displayTitle,
      'description': displayDescription,
      'photo_urls': photoUrls,
      'location_lat': lat,
      'location_lng': lng,
      'address_label': displayLocation,
      'job_mode': jobMode,
      'budget_type': 'fixed',
      'budget_fixed': fee,
      'budget_min': fee,
      'budget_max': fee,
      'service_type': 'home_visit',
    };

    if (jobMode == 'scheduled' && preferredDate != null) {
      payload['scheduled_for'] = _scheduledDateTime().toUtc().toIso8601String();
    }

    return payload;
  }

  DateTime _scheduledDateTime() {
    final DateTime date = preferredDate!;
    final int hour = switch (timeWindow) {
      'Afternoon (12pm - 5pm)' => 12,
      'Evening (5pm - 9pm)' => 17,
      _ => 8,
    };
    return DateTime(date.year, date.month, date.day, hour);
  }
}
