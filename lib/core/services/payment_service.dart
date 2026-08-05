import '../network/api_client.dart';

class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  final ApiClient _api = ApiClient.instance;

  /// Initializes Paystack checkout payment for a job
  Future<Map<String, dynamic>> initializePayment({
    required String jobId,
    String? applicationId,
  }) async {
    final dynamic response = await _api.post(
      '/payments/initialize',
      body: <String, dynamic>{
        'jobId': jobId,
        if (applicationId != null) 'applicationId': applicationId,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  /// Verifies a reference on Paystack
  Future<Map<String, dynamic>> verifyPayment(String reference) async {
    final dynamic response = await _api.get('/payments/verify/$reference');
    return Map<String, dynamic>.from(response as Map);
  }

  /// Saves the artisan's payout MoMo configuration details
  Future<Map<String, dynamic>> savePayoutDetails({
    required String network,
    required String accountNumber,
    required String accountName,
  }) async {
    final dynamic response = await _api.post(
      '/payments/payout-details',
      body: <String, dynamic>{
        'network': network,
        'accountNumber': accountNumber,
        'accountName': accountName,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  /// Fetches the worker's payout details configuration
  Future<Map<String, dynamic>?> getPayoutDetails() async {
    try {
      final dynamic response = await _api.get('/payments/payout-details');
      if (response == null) return null;
      return Map<String, dynamic>.from(response as Map);
    } catch (_) {
      return null;
    }
  }
}
