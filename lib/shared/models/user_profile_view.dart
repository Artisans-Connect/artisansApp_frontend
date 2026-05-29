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
    // If it comes from the API, we need to map the backend role to UserRole
    final roleStr = json['role'] as String?;
    final role = roleStr == 'artisan' ? UserRole.worker : UserRole.client;

    // The backend might return worker_profile object embedded
    final workerProfile = json['worker_profile'] as Map<String, dynamic>?;

    return UserProfileViewData(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      role: role,
      phone: json['phone'] as String?,
      bio: workerProfile?['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      locationLabel: workerProfile?['location_name'] as String?,
      rating: (workerProfile?['rating'] as num?)?.toDouble(),
      totalJobs: workerProfile?['jobs_completed'] as int?,
      skills: workerProfile?['skills'] != null 
          ? List<String>.from(workerProfile!['skills']) 
          : const <String>[],
      serviceAreas: workerProfile?['service_areas'] != null 
          ? List<String>.from(workerProfile!['service_areas']) 
          : const <String>[],
      experienceBand: workerProfile?['experience_level'] as String?,
      isVerified: workerProfile?['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role == UserRole.worker ? 'artisan' : 'client',
      'phone': phone,
      'avatar_url': avatarUrl,
      // The rest depends on if we are sending or receiving, 
      // typically we only need to deserialize profiles fetched from the API
    };
  }
}
