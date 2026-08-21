import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:artisans_app/core/constants/app_constants.dart';
import 'package:artisans_app/core/errors/api_exception.dart';

export 'package:artisans_app/core/errors/api_exception.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._();
  ApiClient._();

  static const Duration requestTimeout = Duration(seconds: 12);

  final String baseUrl = AppConstants.expressApiBaseUrl;

  Future<Map<String, String>> _getHeaders() async {
    Session? session = Supabase.instance.client.auth.currentSession;
    if (session != null && (session.isExpired || session.accessToken.isEmpty)) {
      try {
        final AuthResponse response = await Supabase.instance.client.auth.refreshSession();
        session = response.session;
      } catch (_) {}
    }
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (session != null && session.accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['success'] == false) {
          throw ApiException(
            response.statusCode,
            _readErrorMessage(decoded),
            decoded['code'] as String?,
          );
        }
        if (decoded.containsKey('data')) {
          return decoded['data'];
        }
      }
      return decoded;
    }

    String message = 'An error occurred';
    String? code;
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        message = _readErrorMessage(decoded);
        code = decoded['code'] as String?;
      }
    } catch (_) {
      if (response.body.isNotEmpty && response.body.length < 200) {
        message = response.body;
      }
    }
    if (response.statusCode == 404 &&
        (message.startsWith('Cannot ') || message.contains('Cannot '))) {
      message = 'This feature is not available on the current server yet.';
      code = 'ROUTE_NOT_AVAILABLE';
    }
    throw ApiException(response.statusCode, message, code);
  }

  String _readErrorMessage(Map<String, dynamic> body) {
    final dynamic error = body['error'];
    if (error is String && error.isNotEmpty) return error;
    if (error is Map<String, dynamic>) {
      final dynamic msg = error['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    final dynamic message = body['message'];
    if (message is String && message.isNotEmpty) return message;
    return 'An error occurred';
  }

  Future<dynamic> _request(Future<http.Response> Function() send) async {
    try {
      http.Response response = await send().timeout(requestTimeout);
      if (response.statusCode == 401) {
        try {
          await Supabase.instance.client.auth.refreshSession();
          response = await send().timeout(requestTimeout);
        } catch (_) {}
      }
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on TimeoutException catch (e) {
      throw NetworkException(e);
    } on http.ClientException catch (e) {
      throw NetworkException(e);
    } on FormatException {
      throw const ApiException(0, 'Invalid response from server');
    }
  }

  Future<dynamic> get(String endpoint) {
    final uri = Uri.parse('$baseUrl$endpoint');
    return _request(() async => http.get(uri, headers: await _getHeaders()));
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) {
    final uri = Uri.parse('$baseUrl$endpoint');
    return _request(() async {
      final headers = await _getHeaders();
      if (extraHeaders != null) headers.addAll(extraHeaders);
      return http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<dynamic> put(String endpoint, {dynamic body}) {
    final uri = Uri.parse('$baseUrl$endpoint');
    return _request(() async => http.put(
          uri,
          headers: await _getHeaders(),
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> patch(String endpoint, {dynamic body}) {
    final uri = Uri.parse('$baseUrl$endpoint');
    return _request(() async => http.patch(
          uri,
          headers: await _getHeaders(),
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> delete(String endpoint) {
    final uri = Uri.parse('$baseUrl$endpoint');
    return _request(() async => http.delete(uri, headers: await _getHeaders()));
  }
}
