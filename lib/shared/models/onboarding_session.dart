import 'package:artisans_app/shared/models/user_profile_view.dart';

/// UI-phase session state set at role selection and updated through onboarding.
class OnboardingSession {
  OnboardingSession._();

  static final OnboardingSession instance = OnboardingSession._();

  UserRole? role;
  String? fullName;
  String? phone;
  final Set<String> selectedTrades = <String>{};
  final Set<String> serviceAreas = <String>{};
  String? experienceBand;
  String? locationLabel;
  String? avatarUrl;
  String? bio;
  String? hourlyRateNote;

  bool get isClient => role == UserRole.client;
  bool get isWorker => role == UserRole.worker;
  bool get hasRole => role != null;

  void reset() {
    role = null;
    fullName = null;
    phone = null;
    selectedTrades.clear();
    serviceAreas.clear();
    experienceBand = null;
    locationLabel = null;
    avatarUrl = null;
    bio = null;
    hourlyRateNote = null;
  }

  void setRole(UserRole value) {
    role = value;
  }

  void setRoleFromString(String value) {
    role = value == 'client' ? UserRole.client : UserRole.worker;
  }
}
