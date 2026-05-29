import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/api_client.dart';
import '../session/app_user_session.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final _supabaseAuth = Supabase.instance.client.auth;
  final _apiClient = ApiClient.instance;
  final _session = AppUserSession.instance;

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    // 1. Sign up with Supabase
    final response = await _supabaseAuth.signUp(
      email: email,
      password: password,
    );
    
    if (response.user == null) {
      throw Exception('Sign up failed: No user returned');
    }

    // 2. Create profile in Express backend
    final profileData = await _apiClient.post(
      '/profiles',
      body: {
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        // Optional default role or handled by backend, usually 'client' by default. Let backend handle it or we can pass it if required.
      },
    );

    // 3. Update session
    final appUser = AppUser.fromJson(profileData);
    _session.updateUser(appUser);
    
    return appUser;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    // 1. Sign in with Supabase
    final response = await _supabaseAuth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user == null) {
      throw Exception('Sign in failed: No user returned');
    }

    // 2. Fetch profile from Express backend
    return await getCurrentUser();
  }

  Future<AppUser> getCurrentUser() async {
    final profileData = await _apiClient.get('/profiles/me');
    final appUser = AppUser.fromJson(profileData);
    _session.updateUser(appUser);
    return appUser;
  }

  Future<void> signOut() async {
    await _supabaseAuth.signOut();
    _session.clear();
  }
}
