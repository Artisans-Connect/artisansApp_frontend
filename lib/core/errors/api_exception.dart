/// Thrown when the Express API returns a non-success status.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message, [this.code]);

  final int statusCode;
  final String message;
  final String? code;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidation => statusCode == 400;
  bool get isConflict => statusCode == 409;

  @override
  String toString() => message.isNotEmpty ? message : 'ApiException($statusCode)';
}

/// Thrown when the device cannot reach the API (offline, DNS, timeout).
class NetworkException implements Exception {
  const NetworkException([this.cause]);

  final Object? cause;

  @override
  String toString() => 'NetworkException($cause)';
}
