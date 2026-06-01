import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppUser {
  final String id;
  final String email;
  final String role;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? locationLabel;
  final String? experienceBand;
  final List<String> skills;
  final List<String> serviceAreas;
  final double? hourlyRate;
  final String? rateType;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.locationLabel,
    this.experienceBand,
    this.skills = const <String>[],
    this.serviceAreas = const <String>[],
    this.hourlyRate,
    this.rateType,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? worker = json['worker'] as Map<String, dynamic>?;
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      locationLabel: json['location_label'] as String?,
      experienceBand: json['experience_band'] as String?,
      skills: worker?['skills'] != null
          ? List<String>.from(worker!['skills'] as Iterable<dynamic>)
          : <String>[],
      serviceAreas: worker?['service_areas'] != null
          ? List<String>.from(worker!['service_areas'] as Iterable<dynamic>)
          : <String>[],
      hourlyRate: worker?['hourly_rate'] != null
          ? double.tryParse(worker!['hourly_rate'].toString())
          : null,
      rateType: worker?['rate_type'] as String?,
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
