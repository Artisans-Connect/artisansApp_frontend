import 'package:artisans_app/features/auth/models/password_strength.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rejects short and single-category passwords', () {
    expect(PasswordPolicy.evaluate('abc').isAcceptable, isFalse);
    expect(PasswordPolicy.evaluate('abcdefgh').isAcceptable, isFalse);
  });

  test('accepts mixed passwords from fair upward', () {
    final fair = PasswordPolicy.evaluate('abcdef12');
    final good = PasswordPolicy.evaluate('Abcdef1234');
    final strong = PasswordPolicy.evaluate('Abcdef1234!@');

    expect(fair.level, PasswordStrengthLevel.fair);
    expect(fair.isAcceptable, isTrue);
    expect(good.level, PasswordStrengthLevel.good);
    expect(good.isAcceptable, isTrue);
    expect(strong.level, PasswordStrengthLevel.strong);
    expect(strong.isAcceptable, isTrue);
  });

  test('rejects whitespace and common passwords', () {
    expect(PasswordPolicy.evaluate('abc 1234').isAcceptable, isFalse);
    expect(PasswordPolicy.evaluate('password123').isAcceptable, isFalse);
  });
}
