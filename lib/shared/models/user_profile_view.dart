enum UserRole { client, worker }

class UserProfileViewData {
  const UserProfileViewData({
    required this.id,
    required this.fullName,
    required this.role,
    this.phone,
    this.bio,
    this.avatarUrl,
    this.locationLabel,
    this.rating,
    this.totalJobs,
    this.skills = const <String>[],
    this.serviceAreas = const <String>[],
    this.experienceBand,
    this.isVerified = false,
  });

  final String id;
  final String fullName;
  final UserRole role;
  final String? phone;
  final String? bio;
  final String? avatarUrl;
  final String? locationLabel;
  final double? rating;
  final int? totalJobs;
  final List<String> skills;
  final List<String> serviceAreas;
  final String? experienceBand;
  final bool isVerified;

  bool get isWorker => role == UserRole.worker;
  bool get isClient => role == UserRole.client;

  factory UserProfileViewData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? workerProfile =
        (json['worker'] as Map<String, dynamic>?) ??
        (json['worker_profile'] as Map<String, dynamic>?);
    final String roleStr = workerProfile != null
        ? 'worker'
        : (json['signup_type'] ?? json['role'] ?? 'client').toString();
    final UserRole role = roleStr == 'worker' ? UserRole.worker : UserRole.client;

    return UserProfileViewData(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      role: role,
      phone: json['phone'] as String?,
      bio: json['bio'] as String? ?? workerProfile?['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      locationLabel:
          json['location_label'] as String? ?? workerProfile?['location_label'] as String?,
      rating: (workerProfile?['rating'] as num?)?.toDouble() ??
          (json['rating'] as num?)?.toDouble(),
      totalJobs: (workerProfile?['total_jobs'] as num?)?.toInt() ??
          (json['total_jobs'] as num?)?.toInt(),
      skills: workerProfile?['skills'] != null
          ? List<String>.from(workerProfile!['skills'] as Iterable<dynamic>)
          : const <String>[],
      serviceAreas: workerProfile?['service_areas'] != null
          ? List<String>.from(workerProfile!['service_areas'] as Iterable<dynamic>)
          : const <String>[],
      experienceBand: workerProfile?['experience_band'] as String? ??
          json['experience_band'] as String?,
      isVerified: (workerProfile?['is_verified'] as bool?) ??
          (json['is_verified'] as bool?) ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'signup_type': role == UserRole.worker ? 'worker' : 'client',
      'last_active_mode': role == UserRole.worker ? 'worker' : 'client',
      'phone': phone,
      'avatar_url': avatarUrl,
      // The rest depends on if we are sending or receiving, 
      // typically we only need to deserialize profiles fetched from the API
    };
  }
}
