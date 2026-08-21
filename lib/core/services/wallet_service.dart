import 'package:artisans_app/core/network/api_client.dart';

class WalletService {
  WalletService._();
  static final WalletService instance = WalletService._();

  final ApiClient _apiClient = ApiClient.instance;

  Future<Map<String, dynamic>> getWallet() async {
    final response = await _apiClient.get('/wallet');
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> topupWallet({
    required double amount,
    required String reference,
  }) async {
    final response = await _apiClient.post(
      '/wallet/topup',
      body: {
        'amount': amount,
        'reference': reference,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> requestPayout({
    required double amount,
    required String channel,
    required String accountNumber,
    required String accountName,
    String bankCode = 'MTN',
  }) async {
    final response = await _apiClient.post(
      '/payouts/request',
      body: {
        'amount': amount,
        'channel': channel,
        'accountNumber': accountNumber,
        'accountName': accountName,
        'bankCode': bankCode,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<List<dynamic>> getPayoutHistory() async {
    final response = await _apiClient.get('/payouts/history');
    return response as List<dynamic>;
  }
}
