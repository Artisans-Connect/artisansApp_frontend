import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/models/picked_media.dart';
import '../domain/models/report_category.dart';
import '../domain/models/report_model.dart';

class ReportsService {
  static final ReportsService instance = ReportsService._();
  ReportsService._();

  final ApiClient _apiClient = ApiClient.instance;

  Future<SafetyReport> submitReport({
    required ReportCategory category,
    required String description,
    String? reportedId,
    String? bookingId,
    String? chatId,
    bool isEmergency = false,
    List<PickedMedia> evidenceFiles = const [],
  }) async {
    // 1. Upload evidence media to storage bucket if present
    final List<String> attachmentUrls = [];
    for (final media in evidenceFiles) {
      try {
        final url = await StorageService.instance.uploadReportEvidence(media);
        if (url != null && url.isNotEmpty) {
          attachmentUrls.add(url);
        }
      } catch (e) {
        // Fallback or continue if single upload fails
      }
    }

    // 2. Post report to backend
    final response = await _apiClient.post(
      '/reports',
      body: {
        'category': category.key,
        'description': description,
        if (reportedId != null && reportedId.isNotEmpty) 'reported_id': reportedId,
        if (bookingId != null && bookingId.isNotEmpty) 'booking_id': bookingId,
        if (chatId != null && chatId.isNotEmpty) 'chat_id': chatId,
        'is_emergency': isEmergency,
        'attachments': attachmentUrls,
      },
    );

    if (response is Map<String, dynamic>) {
      return SafetyReport.fromJson(response);
    }
    throw const ApiException(500, 'Invalid server response for report submission');
  }

  Future<List<SafetyReport>> getMyReports() async {
    final response = await _apiClient.get('/reports/my');
    if (response is List) {
      return response
          .map((item) => SafetyReport.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>?> getBookingReportContext(String bookingId) async {
    try {
      final response = await _apiClient.get('/reports/context/$bookingId');
      if (response is Map<String, dynamic>) return response;
    } catch (_) {}
    return null;
  }

  Future<bool> blockUser({required String blockedId, String? reason}) async {
    final response = await _apiClient.post(
      '/reports/block',
      body: {
        'blocked_id': blockedId,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
    return response != null;
  }

  Future<bool> unblockUser(String blockedId) async {
    final response = await _apiClient.delete('/reports/block/$blockedId');
    return response != null;
  }

  Future<List<Map<String, dynamic>>> getBlockedUsers() async {
    final response = await _apiClient.get('/reports/blocks');
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> checkBlockStatus(String targetUserId) async {
    try {
      final response = await _apiClient.get('/reports/block-status/$targetUserId');
      if (response is Map<String, dynamic>) {
        return response;
      }
    } catch (_) {}
    return {'is_blocked': false, 'is_blocked_by_me': false, 'is_blocked_by_them': false};
  }
}
