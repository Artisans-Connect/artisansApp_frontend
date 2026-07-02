import '../network/api_client.dart';

/// Fee breakdown returned by the pricing estimate API.
class FeeEstimate {
  const FeeEstimate({
    required this.minimumFee,
    required this.baseServiceFee,
    required this.distanceCost,
    required this.urgencyPremium,
    required this.verificationPremium,
    required this.verifiedWorkerMarketPremium,
  });

  final double minimumFee;
  final double baseServiceFee;
  final double distanceCost;
  final double urgencyPremium;
  final double verificationPremium;
  final double verifiedWorkerMarketPremium;

  factory FeeEstimate.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> breakdown =
        json['breakdown'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return FeeEstimate(
      minimumFee: (json['minimum_fee'] as num?)?.toDouble() ?? 40,
      baseServiceFee:
          (breakdown['base_service_fee'] as num?)?.toDouble() ?? 0,
      distanceCost: (breakdown['distance_cost'] as num?)?.toDouble() ?? 0,
      urgencyPremium:
          (breakdown['urgency_premium'] as num?)?.toDouble() ?? 0,
      verificationPremium:
          (breakdown['verification_premium'] as num?)?.toDouble() ?? 0,
      verifiedWorkerMarketPremium:
          (breakdown['verified_worker_market_premium'] as num?)?.toDouble() ??
              0,
    );
  }

  double get total => minimumFee;

  String formatGhs(double amount) => 'GH₵${amount.toStringAsFixed(0)}';
}

class PricingService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Fetches a smart fee estimate from the backend.
  Future<FeeEstimate> estimateFee({
    required String categoryId,
    required double locationLat,
    required double locationLng,
    required String jobMode,
  }) async {
    final dynamic response = await _apiClient.post(
      '/pricing/estimate',
      body: <String, dynamic>{
        'category_id': categoryId,
        'location_lat': locationLat,
        'location_lng': locationLng,
        'job_mode': jobMode,
      },
    );
    if (response is Map<String, dynamic>) {
      return FeeEstimate.fromJson(response);
    }
    // Fallback if response shape is unexpected
    return const FeeEstimate(
      minimumFee: 40,
      baseServiceFee: 60,
      distanceCost: 0,
      urgencyPremium: 0,
      verificationPremium: 0,
      verifiedWorkerMarketPremium: 0,
    );
  }
}
