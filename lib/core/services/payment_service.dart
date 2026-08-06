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

  /// Proposes a new extra charge or a counter-offer
  Future<Map<String, dynamic>> proposeExtraCharge({
    required String jobId,
    required double amount,
    required String description,
    required String proposedBy,
  }) async {
    final dynamic response = await _api.post(
      '/payments/extra-charge/propose',
      body: <String, dynamic>{
        'jobId': jobId,
        'amount': amount,
        'description': description,
        'proposedBy': proposedBy,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  /// Accepts an extra charge proposal or counter-offer
  Future<Map<String, dynamic>> acceptExtraCharge({
    required String extraChargeId,
  }) async {
    final dynamic response = await _api.post(
      '/payments/extra-charge/accept',
      body: <String, dynamic>{
        'extraChargeId': extraChargeId,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  /// Initializes Paystack checkout payment for an extra charge
  Future<Map<String, dynamic>> initializeExtraChargePayment({
    required String extraChargeId,
  }) async {
    final dynamic response = await _api.post(
      '/payments/extra-charge/initialize',
      body: <String, dynamic>{
        'extraChargeId': extraChargeId,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  /// Counters an extra charge request with a new amount
  Future<Map<String, dynamic>> counterExtraCharge({
    required String extraChargeId,
    required double amount,
  }) async {
    final dynamic response = await _api.post(
      '/payments/extra-charge/counter',
      body: <String, dynamic>{
        'extraChargeId': extraChargeId,
        'amount': amount,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  /// Calculates final settlement amounts for a completed job
  Future<Map<String, dynamic>> calculateSettlement(String jobId) async {
    final dynamic response = await _api.get('/payments/settlement/$jobId');
    return Map<String, dynamic>.from(response as Map);
  }

  /// Initializes final settlement checkout session or releases escrow
  Future<Map<String, dynamic>> checkoutSettlement(String jobId) async {
    final dynamic response = await _api.post('/payments/settlement/$jobId/checkout');
    return Map<String, dynamic>.from(response as Map);
  }
}

