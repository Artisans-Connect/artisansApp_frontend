import '../cache/cache_keys.dart';
import '../cache/cache_store.dart';
import '../network/api_client.dart';
import '../session/app_user_session.dart';

class ProfileService {
  static final ProfileService instance = ProfileService._();
  ProfileService._();

  final _apiClient = ApiClient.instance;
  final _session = AppUserSession.instance;

  Future<AppUser> getMyProfile({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final Map<String, dynamic>? cached =
          await CacheStore.instance.get<Map<String, dynamic>>(
        CacheKeys.profileMe,
        CacheKeys.profileTtl,
        decode: (dynamic json) => Map<String, dynamic>.from(json as Map),
      );
      if (cached != null) {
        final appUser = AppUser.fromJson(cached);
        _session.updateUser(appUser);
        return appUser;
      }
    }

    final profileData = await _apiClient.get('/profiles/me');
    final map = Map<String, dynamic>.from(profileData as Map);
    await CacheStore.instance.put(CacheKeys.profileMe, map);
    final appUser = AppUser.fromJson(map);
    _session.updateUser(appUser);
    return appUser;
  }

  Future<AppUser> updateProfile(Map<String, dynamic> body) async {
    final profileData = await _apiClient.put('/profiles/me', body: body);
    final map = Map<String, dynamic>.from(profileData as Map);
    await CacheStore.instance.put(CacheKeys.profileMe, map);
    final appUser = AppUser.fromJson(map);
    _session.updateUser(appUser);
    return appUser;
  }

  Future<Map<String, dynamic>> getProfileById(String userId) async {
    final profileData = await _apiClient.get('/profiles/$userId');
    return Map<String, dynamic>.from(profileData as Map);
  }

  Future<Map<String, dynamic>> addGalleryPhoto(String url) async {
    final response = await _apiClient.post('/profiles/me/gallery', body: {'url': url});
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> deleteGalleryPhoto(String url) async {
    final response = await _apiClient.post('/profiles/me/gallery/delete', body: {'url': url});
    return Map<String, dynamic>.from(response as Map);
  }
}
