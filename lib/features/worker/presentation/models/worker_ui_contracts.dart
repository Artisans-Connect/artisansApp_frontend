/// Frontend-facing worker contracts used by presentation-layer screens.
///
/// Keep these enums and keys stable so backend integration can map API
/// responses into these values without forcing UI rewrites.
enum WorkerRequestLifecycle {
  requested,
  accepted,
  inProgress,
  completed,
  cancelled,
}

enum WorkerAvailabilityStatus { online, offline }

extension WorkerAvailabilityStatusX on WorkerAvailabilityStatus {
  bool get isOnline => this == WorkerAvailabilityStatus.online;
}

/// Canonical payload fields expected by worker request cards/detail screens.
///
/// These keys mirror existing UI usage and can be used by adapters/mappers.
abstract final class WorkerUiFieldKeys {
  static const requestId = 'id';
  static const title = 'title';
  static const category = 'category';
  static const description = 'description';
  static const addressLabel = 'addressLabel';
  static const clientName = 'clientName';
  static const clientRating = 'clientRating';
  static const reviewCount = 'reviewCount';
  static const urgency = 'urgency';
  static const estimate = 'estimate';
  static const distanceKm = 'distanceKm';
}
