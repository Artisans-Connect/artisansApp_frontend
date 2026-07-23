import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum PasswordStrengthLevel {
  empty,
  weak,
  fair,
  good,
  strong,
}

class PasswordStrength {
  const PasswordStrength({
    required this.level,
    required this.score,
    required this.label,
    required this.hint,
    required this.color,
    required this.isAcceptable,
  });

  final PasswordStrengthLevel level;
  final int score;
  final String label;
  final String hint;
  final Color color;
  final bool isAcceptable;
}

class PasswordPolicy {
  static const int minLength = 8;

  static PasswordStrength evaluate(String password) {
    if (password.isEmpty) {
      return const PasswordStrength(
        level: PasswordStrengthLevel.empty,
        score: 0,
        label: 'Password strength',
        hint: 'Use at least 8 characters with letters, numbers, and a symbol.',
        color: AppColors.outlineVariant,
        isAcceptable: false,
      );
    }

    final int categories = _categoryCount(password);
    final bool hasMinLength = password.length >= minLength;
    final bool hasNoWhitespace = !RegExp(r'\s').hasMatch(password);
    final bool hasCommonPassword = _commonPasswords.contains(
      password.toLowerCase(),
    );

    if (!hasMinLength ||
        categories < 2 ||
        !hasNoWhitespace ||
        hasCommonPassword) {
      return PasswordStrength(
        level: PasswordStrengthLevel.weak,
        score: 1,
        label: 'Weak',
        hint: _firstBlockingHint(
          password: password,
          categories: categories,
          hasNoWhitespace: hasNoWhitespace,
          hasCommonPassword: hasCommonPassword,
        ),
        color: AppColors.error,
        isAcceptable: false,
      );
    }

    if (password.length >= 12 && categories >= 4) {
      return const PasswordStrength(
        level: PasswordStrengthLevel.strong,
        score: 4,
        label: 'Strong',
        hint: 'Looks strong.',
        color: AppColors.success,
        isAcceptable: true,
      );
    }

    if (password.length >= 10 && categories >= 3) {
      return const PasswordStrength(
        level: PasswordStrengthLevel.good,
        score: 3,
        label: 'Good',
        hint: 'Add more length or another symbol to make it stronger.',
        color: AppColors.secondary,
        isAcceptable: true,
      );
    }

    return const PasswordStrength(
      level: PasswordStrengthLevel.fair,
      score: 2,
      label: 'Fair',
      hint: 'Add uppercase letters, numbers, or symbols.',
      color: AppColors.secondary,
      isAcceptable: true,
    );
  }

  static String? validate(String? value) {
    final String password = value ?? '';
    final PasswordStrength strength = evaluate(password);
    if (strength.isAcceptable) return null;
    return strength.hint;
  }

  static int _categoryCount(String password) {
    int count = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) count++;
    if (RegExp(r'[A-Z]').hasMatch(password)) count++;
    if (RegExp(r'[0-9]').hasMatch(password)) count++;
    if (RegExp(r'[^A-Za-z0-9\s]').hasMatch(password)) count++;
    return count;
  }

  static String _firstBlockingHint({
    required String password,
    required int categories,
    required bool hasNoWhitespace,
    required bool hasCommonPassword,
  }) {
    if (password.length < minLength) {
      return 'Use at least 8 characters.';
    }
    if (!hasNoWhitespace) {
      return 'Remove spaces from your password.';
    }
    if (hasCommonPassword) {
      return 'Avoid common passwords.';
    }
    if (categories < 2) {
      return 'Mix letters with numbers or symbols.';
    }
    return 'Choose a stronger password.';
  }

  static const Set<String> _commonPasswords = <String>{
    'password',
    'password1',
    'password123',
    '12345678',
    '123456789',
    'qwerty123',
    'admin123',
    'letmein123',
    'craftmatch',
  };
}
