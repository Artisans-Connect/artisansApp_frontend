import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_exception.dart';
import 'auth_failure.dart';

/// Maps any thrown value to a short, user-facing message.
String userMessageFor(Object? error, {String? fallback}) {
  if (error == null) {
    return fallback ?? 'Something went wrong. Please try again.';
  }

  if (error is AuthFailure) {
    return error.message;
  }

  if (error is ApiException) {
    return _apiMessage(error);
  }

  if (error is NetworkException) {
    return 'No connection. Check your internet and try again.';
  }

  if (error is AuthException) {
    return _authMessage(error);
  }

  final String raw = error.toString();
  if (raw.startsWith('ApiException')) {
    final match = RegExp(r'ApiException\(\d+\): (.+?)(?: \(|$)').firstMatch(raw);
    if (match != null) return match.group(1)!.trim();
  }

  if (raw.contains('SocketException') ||
      raw.contains('Failed host lookup') ||
      raw.contains('Connection refused') ||
      raw.contains('ClientException')) {
    return 'No connection. Check your internet and try again.';
  }

  if (raw.startsWith('Exception: ')) {
    return raw.substring('Exception: '.length);
  }

  return fallback ?? 'Something went wrong. Please try again.';
}

String _apiMessage(ApiException e) {
  switch (e.code) {
    case 'UNAUTHORIZED':
      return e.message.isNotEmpty
          ? e.message
          : 'Your session expired. Please sign in again.';
    case 'PROFILE_NOT_FOUND':
      return 'We could not find your profile. Try signing in again.';
    case 'PROFILE_EXISTS':
      return 'An account with this email already exists.';
    case 'JOB_ALREADY_TAKEN':
      return 'This job was already accepted by another artisan.';
    case 'JOB_NOT_FOUND':
      return 'This job is no longer available.';
    case 'REVIEW_EXISTS':
      return 'You have already reviewed this job.';
    case 'FORBIDDEN':
      return e.message.isNotEmpty ? e.message : 'You do not have permission to do that.';
    case 'VALIDATION_ERROR':
      return e.message.isNotEmpty ? e.message : 'Please check your input and try again.';
    case 'NOT_FOUND':
      return e.message.isNotEmpty ? e.message : 'The requested resource was not found.';
    default:
      if (e.message.isNotEmpty && e.message != 'An error occurred') {
        return e.message;
      }
      if (e.statusCode >= 500) {
        return 'Server error. Please try again in a moment.';
      }
      return 'Something went wrong. Please try again.';
  }
}

String _authMessage(AuthException e) {
  final String msg = e.message.toLowerCase();
  if (msg.contains('invalid login credentials') ||
      msg.contains('invalid email or password')) {
    return 'Incorrect email or password.';
  }
  if (msg.contains('email not confirmed')) {
    return 'Please confirm your email before signing in.';
  }
  if (msg.contains('user already registered')) {
    return 'An account with this email already exists.';
  }
  if (msg.contains('password')) {
    return e.message;
  }
  return e.message.isNotEmpty ? e.message : 'Authentication failed. Please try again.';
}
