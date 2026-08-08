import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';
import '../network/api_client.dart';
import 'profile_service.dart';

class VerificationContext {
  const VerificationContext({
    required this.isVerified,
    this.status,
    this.applicationNumber,
    this.verificationLevel,
  });

  final bool isVerified;
  final String? status;
  final String? applicationNumber;
  final String? verificationLevel;

  bool get hasApplication =>
      applicationNumber != null && applicationNumber!.trim().isNotEmpty;

  bool get hasUntrackableStatus =>
      status != null && status!.isNotEmpty && !hasApplication;

  factory VerificationContext.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? worker =
        json['worker'] as Map<String, dynamic>?;
    final Map<String, dynamic>? verification =
        json['verification'] as Map<String, dynamic>?;
    return VerificationContext(
      isVerified: worker?['is_verified'] as bool? ?? false,
      status: verification?['status'] as String?,
      applicationNumber: verification?['application_number'] as String?,
      verificationLevel: verification?['verification_level'] as String?,
    );
  }
}

class VerificationService {
  static final VerificationService instance = VerificationService._();
  VerificationService._();

  final ApiClient _apiClient = ApiClient.instance;

  Future<VerificationContext> getMyVerification() async {
    final dynamic response = await _apiClient.get('/verification/me');
    return VerificationContext.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<Uri> createPortalUri() async {
    String code = '';
    try {
      final dynamic response = await _apiClient.post('/verification/handoff');
      final map = Map<String, dynamic>.from(response as Map);
      code = map['handoff_code'] as String? ?? '';
    } on ApiException catch (e) {
      if (e.code != 'ROUTE_NOT_AVAILABLE' && !e.isNotFound) rethrow;
    }
    return Uri.parse(AppConstants.verificationPortalUrl).replace(
      queryParameters: <String, String>{
        if (code.isNotEmpty) 'handoff': code,
        if (code.isEmpty) 'signin': 'true',
      },
    );
  }

  Future<void> openPortalAndRefreshProfile() async {
    final uri = await createPortalUri();
    bool launched = false;
    if (kIsWeb) {
      launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
    if (!launched) {
      throw StateError('Could not open verification portal.');
    }
    unawaited(ProfileService.instance.getMyProfile(forceRefresh: true));
  }
}
