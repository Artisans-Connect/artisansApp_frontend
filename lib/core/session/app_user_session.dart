import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppUser {
  final String id;
  final String email;
  final String signupType;
  final String lastActiveMode;
  final bool hasWorkerProfile;
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
  final bool isVerified;
  final String? verificationStatus;
  final String? verificationLevel;

  AppUser({
    required this.id,
    required this.email,
    required this.signupType,
    required this.lastActiveMode,
    required this.hasWorkerProfile,
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
    this.isVerified = false,
    this.verificationStatus,
    this.verificationLevel,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? worker = json['worker'] as Map<String, dynamic>?;
    final bool hasWorker = json['has_worker_profile'] as bool? ?? worker != null;
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      signupType: json['signup_type'] as String? ?? 'client',
      lastActiveMode: json['last_active_mode'] as String? ?? 'client',
      hasWorkerProfile: hasWorker,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      locationLabel: json['location_label'] as String?,
      experienceBand: worker?['experience_band'] as String? ?? json['experience_band'] as String?,
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
      isVerified: worker?['is_verified'] as bool? ?? false,
      verificationStatus: json['verification_status'] as String?,
      verificationLevel: json['verification_level'] as String?,
    );
  }

  AppUser copyWith({
    String? lastActiveMode,
    bool? hasWorkerProfile,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? locationLabel,
    String? experienceBand,
    List<String>? skills,
    List<String>? serviceAreas,
    double? hourlyRate,
    String? rateType,
    bool? isVerified,
    String? verificationStatus,
    String? verificationLevel,
  }) {
    return AppUser(
      id: id,
      email: email,
      signupType: signupType,
      lastActiveMode: lastActiveMode ?? this.lastActiveMode,
      hasWorkerProfile: hasWorkerProfile ?? this.hasWorkerProfile,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      locationLabel: locationLabel ?? this.locationLabel,
      experienceBand: experienceBand ?? this.experienceBand,
      skills: skills ?? this.skills,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rateType: rateType ?? this.rateType,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationLevel: verificationLevel ?? this.verificationLevel,
    );
  }
}

class AppUserSession extends ChangeNotifier {
  static final AppUserSession instance = AppUserSession._();
  AppUserSession._();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  String get activeMode => _currentUser?.lastActiveMode ?? 'client';

  bool get isWorkerCapable => _currentUser?.hasWorkerProfile ?? false;

  bool get isAuthenticated =>
      Supabase.instance.client.auth.currentSession != null && _currentUser != null;

  void updateUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateActiveMode(String mode) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(lastActiveMode: mode);
    notifyListeners();
  }

  void onboardAsWorker(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    notifyListeners();
  }
}
