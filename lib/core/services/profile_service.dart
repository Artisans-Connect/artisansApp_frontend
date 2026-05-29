import '../network/api_client.dart';
import '../session/app_user_session.dart';

class ProfileService {
  static final ProfileService instance = ProfileService._();
  ProfileService._();

  final _apiClient = ApiClient.instance;
  final _session = AppUserSession.instance;

  Future<AppUser> getMyProfile() async {
    final profileData = await _apiClient.get('/profiles/me');
    final appUser = AppUser.fromJson(profileData);
    _session.updateUser(appUser);
    return appUser;
  }

  Future<AppUser> updateProfile(Map<String, dynamic> body) async {
    final profileData = await _apiClient.put('/profiles/me', body: body);
    final appUser = AppUser.fromJson(profileData);
    _session.updateUser(appUser);
    return appUser;
  }
}
