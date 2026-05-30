import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppUser {
  final String id;
  final String email;
  final String role;
  final String fullName;
  final String? phone;
  final String? avatarUrl;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    this.phone,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class AppUserSession extends ChangeNotifier {
  static final AppUserSession instance = AppUserSession._();
  AppUserSession._();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool get isAuthenticated => Supabase.instance.client.auth.currentSession != null && _currentUser != null;

  void updateUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    notifyListeners();
  }
}
