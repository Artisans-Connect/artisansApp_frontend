enum JobUrgency { asap, scheduled }

enum WorkerJobStatus { incoming, active, completing, completed, cancelled }

enum HistoryStatus { completed, cancelled }

class WorkerJob {
  const WorkerJob({
    required this.id,
    required this.title,
    required this.category,
    this.categoryIconName,
    this.categoryColorHex,
    required this.description,
    required this.addressLabel,
    required this.latitude,
    required this.longitude,
    required this.clientName,
    required this.urgency,
    this.clientId,
    this.clientPhone,
    this.clientAvatarUrl,
    this.clientRating = 4.9,
    this.reviewCount = 12,
    this.isNewClient = false,
    this.isUrgent = false,
    this.rateLabel,
    this.distanceKm,
    this.photoCount = 0,
    this.status = WorkerJobStatus.incoming,
    this.scheduledLabel,
    this.urgencyBadge,
    this.estimateLabel,
    this.estimatedBudgetLabel,
    this.referencePhotoLabels = const [],
    this.cityLine,
    this.postalLine,
    this.mapLabel,
    this.earnedAmount,
    this.historyStatus,
    this.historyDate,
    this.historyRating,
    this.backendStatus,
    this.completionHours,
    this.completionMaterials,
    this.completionNotes,
    this.completionPhotoUrls = const [],
    this.createdAt,
    this.trade,
    this.area,
    this.startedAt,
    this.baseRate,
    this.distanceCost,
    this.urgencyPremium,
    this.grossAmount,
    this.platformFee,
    this.artisanPayout,
    this.applicationDistanceKm,
    this.applicationDistanceCost,
    this.applicationBaseServiceFee,
    this.applicationUrgencyPremium,
    this.applicationTotalQuote,
    this.applicationQuoteCurrency,
  });

  final String id;
  final String title;
  final String category;
  final String? categoryIconName;
  final String? categoryColorHex;
  final String description;
  final String addressLabel;
  final double latitude;
  final double longitude;
  final String clientName;
  final JobUrgency urgency;
  final String? clientId;
  final String? clientPhone;
  final String? clientAvatarUrl;
  final double clientRating;
  final int reviewCount;
  final bool isNewClient;
  final bool isUrgent;
  final String? rateLabel;
  final double? distanceKm;
  final int photoCount;
  final WorkerJobStatus status;
  final String? scheduledLabel;
  final String? urgencyBadge;
  final String? estimateLabel;
  final String? estimatedBudgetLabel;
  final List<String> referencePhotoLabels;
  final String? cityLine;
  final String? postalLine;
  final String? mapLabel;
  final double? earnedAmount;
  final HistoryStatus? historyStatus;
  final String? historyDate;
  final double? historyRating;
  final String? backendStatus;
  final double? completionHours;
  final String? completionMaterials;
  final String? completionNotes;
  final List<String> completionPhotoUrls;
  final DateTime? createdAt;
  final String? trade;
  final String? area;
  final DateTime? startedAt;

  // Settlement details
  final double? baseRate;
  final double? distanceCost;
  final double? urgencyPremium;
  final double? grossAmount;
  final double? platformFee;
  final double? artisanPayout;
  final double? applicationDistanceKm;
  final double? applicationDistanceCost;
  final double? applicationBaseServiceFee;
  final double? applicationUrgencyPremium;
  final double? applicationTotalQuote;
  final String? applicationQuoteCurrency;

  String get urgencyLabel => urgencyBadge ??
      (urgency == JobUrgency.asap ? 'ASAP' : (scheduledLabel ?? 'Scheduled'));

  String get distanceText {
    if (distanceKm == null) return addressLabel;
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).round()} m away';
    }
    return '${distanceKm!.toStringAsFixed(1)} km away';
  }

  String get locationLine {
    if (distanceKm == null) return addressLabel;
    return '${distanceText} • $addressLabel';
  }

  String get estimateDisplay =>
      estimateLabel ?? estimatedBudgetLabel ?? rateLabel ?? '—';

  bool get hasServiceLocation => latitude != 0 || longitude != 0;

  WorkerJob copyWith({WorkerJobStatus? status}) {
    return WorkerJob(
      id: id,
      title: title,
      category: category,
      categoryIconName: categoryIconName,
      categoryColorHex: categoryColorHex,
      description: description,
      addressLabel: addressLabel,
      latitude: latitude,
      longitude: longitude,
      clientName: clientName,
      urgency: urgency,
      clientId: clientId,
      clientPhone: clientPhone,
      clientAvatarUrl: clientAvatarUrl,
      clientRating: clientRating,
      reviewCount: reviewCount,
      isNewClient: isNewClient,
      isUrgent: isUrgent,
      rateLabel: rateLabel,
      distanceKm: distanceKm,
      photoCount: photoCount,
      status: status ?? this.status,
      scheduledLabel: scheduledLabel,
      urgencyBadge: urgencyBadge,
      estimateLabel: estimateLabel,
      estimatedBudgetLabel: estimatedBudgetLabel,
      referencePhotoLabels: referencePhotoLabels,
      cityLine: cityLine,
      postalLine: postalLine,
      mapLabel: mapLabel,
      earnedAmount: earnedAmount,
      historyStatus: historyStatus,
      historyDate: historyDate,
      historyRating: historyRating,
      backendStatus: backendStatus,
      completionHours: completionHours,
      completionMaterials: completionMaterials,
      completionNotes: completionNotes,
      completionPhotoUrls: completionPhotoUrls,
      createdAt: createdAt,
      trade: trade,
      area: area,
      startedAt: startedAt,
      baseRate: baseRate,
      distanceCost: distanceCost,
      urgencyPremium: urgencyPremium,
      grossAmount: grossAmount,
      platformFee: platformFee,
      artisanPayout: artisanPayout,
      applicationDistanceKm: applicationDistanceKm,
      applicationDistanceCost: applicationDistanceCost,
      applicationBaseServiceFee: applicationBaseServiceFee,
      applicationUrgencyPremium: applicationUrgencyPremium,
      applicationTotalQuote: applicationTotalQuote,
      applicationQuoteCurrency: applicationQuoteCurrency,
    );
  }
}
