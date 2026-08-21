import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/models/picked_media.dart';
import '../domain/models/report_category.dart';
import '../domain/models/safety_report.dart';

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

  Future<List<Map<String, dynamic>>> getBlockedUsers({String? role}) async {
    try {
      final queryParam = role != null && role.isNotEmpty ? '?role=$role' : '';
      final response = await _apiClient.get('/reports/blocks$queryParam');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
    } catch (_) {
      // Direct Supabase fallback if API server is offline
      try {
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        final List<Map<String, dynamic>> results = [];

        if (currentUserId != null) {
          try {
            final dynamic userBlocks = await Supabase.instance.client
                .from('user_blocks')
                .select('id, blocked_id, reason, created_at')
                .eq('blocker_id', currentUserId);
            if (userBlocks is List) {
              for (final dynamic b in userBlocks) {
                final bMap = b as Map<String, dynamic>;
                results.add({
                  'id': bMap['id'],
                  'blocked_id': bMap['blocked_id'],
                  'reason': bMap['reason'] ?? 'Blocked by user',
                  'created_at': bMap['created_at'],
                  'is_personal_block': true,
                });
              }
            }
          } catch (_) {}
        }

        var query = Supabase.instance.client
            .from('profiles')
            .select('id, full_name, phone, avatar_url, signup_type, last_active_mode, account_status, suspended_at, suspension_reason, created_at, updated_at, workers(id, skills, rating, total_jobs, is_verified, service_areas)')
            .inFilter('account_status', ['suspended', 'warned']);

        if (role == 'worker') {
          query = query.or('signup_type.eq.worker,last_active_mode.eq.worker');
        } else if (role == 'client') {
          query = query.or('signup_type.eq.client,last_active_mode.eq.client');
        }

        final dynamic suspended = await query;
        if (suspended is List) {
          final existingIds = results.map((r) => r['blocked_id']).toSet();
          for (final dynamic p in suspended) {
            final pMap = p as Map<String, dynamic>;
            if (!existingIds.contains(pMap['id'])) {
              results.add({
                'id': 'platform-${pMap['id']}',
                'blocked_id': pMap['id'],
                'reason': pMap['suspension_reason'] ?? 'Suspended by platform safety & moderation policy',
                'created_at': pMap['suspended_at'] ?? pMap['updated_at'] ?? pMap['created_at'],
                'is_personal_block': false,
                'blocked': pMap,
              });
            }
          }
        }

        if (results.isNotEmpty) return results;
      } catch (_) {}
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
