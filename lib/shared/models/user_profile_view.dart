enum UserRole { client, worker }

class UserProfileViewData {
  const UserProfileViewData({
    required this.id,
    required this.fullName,
    required this.role,
    this.phone,
    this.bio,
    this.avatarUrl,
    this.rating,
    this.totalJobs,
    this.skills = const <String>[],
    this.isVerified = false,
  });

  final String id;
  final String fullName;
  final UserRole role;
  final String? phone;
  final String? bio;
  final String? avatarUrl;
  final double? rating;
  final int? totalJobs;
  final List<String> skills;
  final bool isVerified;

  bool get isWorker => role == UserRole.worker;
}
