import 'package:artisans_app/core/errors/api_exception.dart';
import 'package:artisans_app/core/errors/error_messages.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('userMessageFor', () {
    test('hides raw network exception details', () {
      final message = userMessageFor(
        'ClientException with SocketException: Failed host lookup',
      );

      expect(message, 'Connection problem. Check your internet and try again.');
      expect(message, isNot(contains('SocketException')));
      expect(message, isNot(contains('ClientException')));
    });

    test('hides auth network exception details', () {
      final message = userMessageFor(
        const AuthException(
          'client exception with SocketException: connection failed',
        ),
      );

      expect(message, 'Connection problem. Check your internet and try again.');
    });

    test('keeps normal user-facing string messages', () {
      expect(userMessageFor('Full name is required.'), 'Full name is required.');
    });

    test('maps NetworkException to a friendly message', () {
      expect(
        userMessageFor(const NetworkException()),
        'Connection problem. Check your internet and try again.',
      );
    });
  });
}
