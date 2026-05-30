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

  String? get subcategoryId =>
      data['subcategoryId'] as String? ?? data['subcategory'] as String?;

  String? get subcategoryName => data['subcategoryName'] as String?;

  String? get title => data['title'] as String?;

  String? get description => data['description'] as String?;

  String? get address => data['address'] as String?;

  String? get urgency => data['urgency'] as String?;

  String? get timeWindow => data['timeWindow'] as String?;

  DateTime? get preferredDate {
    final Object? raw = data['preferredDate'];
    if (raw is DateTime) return raw;
    return null;
  }

  double get budgetMin {
    final value = data['budgetMin'] ?? data['projectBudget'];
    if (value is num) return value.toDouble();
    return 0;
  }

  double get budgetMax {
    final value = data['budgetMax'] ?? data['projectBudget'];
    if (value is num) return value.toDouble();
    return budgetMin;
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
      case JobPostWizardStep.title:
        return title != null && title!.trim().length >= 3;
      case JobPostWizardStep.description:
        return description != null && description!.trim().length >= 20;
      case JobPostWizardStep.location:
        return address != null && address!.trim().isNotEmpty;
      case JobPostWizardStep.urgency:
        return budgetMax >= 50;
      case JobPostWizardStep.summary:
        return isValidForStep(JobPostWizardStep.urgency) &&
            isValidForStep(JobPostWizardStep.title);
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
    const double defaultLat = 5.6037;
    const double defaultLng = -0.1870;

    final String urgencyValue = (urgency ?? 'asap').toLowerCase();
    final String jobMode = switch (urgencyValue) {
      'scheduled' => 'scheduled',
      'flexible' => 'flexible',
      _ => 'asap',
    };

    final double minBudget = budgetMin >= 50 ? budgetMin : 50;
    final double maxBudget = budgetMax >= minBudget ? budgetMax : minBudget;

    final Map<String, dynamic> payload = <String, dynamic>{
      'category_id': categoryId,
      'title': displayTitle,
      'description': displayDescription,
      'photo_urls': data['photoUrls'] as List<dynamic>? ?? <dynamic>[],
      'location_lat': (data['locationLat'] as num?)?.toDouble() ?? defaultLat,
      'location_lng': (data['locationLng'] as num?)?.toDouble() ?? defaultLng,
      'address_label': displayLocation,
      'job_mode': jobMode,
      'budget_type': 'range',
      'budget_min': minBudget,
      'budget_max': maxBudget,
      'service_type': 'home_visit',
    };

    if (jobMode == 'scheduled' && preferredDate != null) {
      payload['scheduled_for'] = preferredDate!.toUtc().toIso8601String();
    }

    return payload;
  }
}

/// Subcategory options keyed by parent category id.
class JobPostSubcategoryCatalog {
  JobPostSubcategoryCatalog._();

  static final Map<String, List<Map<String, dynamic>>> byCategoryId =
      <String, List<Map<String, dynamic>>>{
    'plumbing': [
      _sub('plumbing_leaks', 'Leak repair', 'Faucets, pipes, drainage'),
      _sub('plumbing_install', 'Installation', 'Fixtures and appliances'),
    ],
    'electrical': [
      _sub('electrical_wiring', 'Wiring', 'Panels, outlets, lighting'),
      _sub('electrical_repair', 'Repairs', 'Faults and replacements'),
    ],
    'carpentry': [
      _sub('carpentry_furniture', 'Furniture', 'Build and repair'),
      _sub('carpentry_frames', 'Frames & doors', 'Install and adjust'),
    ],
    'cleaning': [
      _sub('cleaning_deep', 'Deep clean', 'Home and office'),
      _sub('cleaning_move', 'Move-in/out', 'Full property clean'),
    ],
    'painting': [
      _sub('painting_interior', 'Interior', 'Walls and ceilings'),
      _sub('painting_exterior', 'Exterior', 'Outdoor surfaces'),
    ],
    'construction': [
      _sub('construction_reno', 'Renovation', 'Remodeling work'),
      _sub('construction_repair', 'Structural repair', 'Masonry and builds'),
    ],
    'hvac': [
      _sub('hvac_ac', 'AC service', 'Cooling units'),
      _sub('hvac_heat', 'Heating', 'Boilers and heaters'),
    ],
    'landscaping': [
      _sub('landscape_lawn', 'Lawn care', 'Mowing and trimming'),
      _sub('landscape_garden', 'Garden design', 'Plants and layout'),
    ],
  };

  static List<Map<String, dynamic>> forCategory(String? categoryId) {
    if (categoryId == null) return all;
    return byCategoryId[categoryId] ?? all;
  }

  static List<Map<String, dynamic>> get all => byCategoryId.values
      .expand((List<Map<String, dynamic>> list) => list)
      .toList();

  static Map<String, dynamic> _sub(
    String id,
    String name,
    String description,
  ) =>
      <String, dynamic>{
        'id': id,
        'name': name,
        'description': description,
      };
}
