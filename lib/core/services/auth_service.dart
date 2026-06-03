import 'package:supabase_flutter/supabase_flutter.dart';

import '../cache/cache_keys.dart';
import '../cache/cache_store.dart';
import '../constants/app_constants.dart';
import '../errors/auth_failure.dart';
import '../network/api_client.dart';
import '../session/app_user_session.dart';
import '../utils/cache_logger.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final _supabaseAuth = Supabase.instance.client.auth;
  final _apiClient = ApiClient.instance;
  final _session = AppUserSession.instance;

  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabaseAuth.signUp(
        email: email,
        password: password,
        emailRedirectTo: AppConstants.supabaseRedirectUrl,
      );

      if (response.user == null) {
        throw const AuthFailure(
          AuthFailureCode.signUpFailed,
          'Sign up failed. Please try again.',
        );
      }

      if (response.session == null) {
        return SignUpOutcome.needsVerification(email);
      }

      return SignUpOutcome.signedIn(email, response.user);
    } on AuthException catch (e) {
      throw _mapAuthException(e, forSignUp: true);
    }
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabaseAuth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthFailure(
          AuthFailureCode.invalidCredentials,
          'Sign in failed. Please try again.',
        );
      }

      return await getCurrentUser(forceRefresh: true);
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } on ApiException catch (e) {
      if (e.code == 'PROFILE_NOT_FOUND') {
        throw const AuthFailure(
          AuthFailureCode.profileNotFound,
          'Your account is confirmed, but your profile is not set up yet.',
        );
      }
      rethrow;
    }
  }

  /// Hydrates session from disk when a Supabase session exists (fast splash bootstrap).
  Future<AppUser?> loadCachedUser() async {
    final Map<String, dynamic>? cached =
        await CacheStore.instance.get<Map<String, dynamic>>(
      CacheKeys.profileMe,
      CacheKeys.profileTtl,
      decode: (dynamic json) => Map<String, dynamic>.from(json as Map),
    );
    if (cached == null) return null;
    final appUser = _appUserFromProfile(cached);
    _session.updateUser(appUser);
    return appUser;
  }

  Future<AppUser> getCurrentUser({bool forceRefresh = false}) async {
    // If not forcing refresh, try to use cached profile
    if (!forceRefresh) {
      final cached = await loadCachedUser();
      if (cached != null) {
        // Verify auth token is still valid before using cached profile
        final isTokenValid = await _isAuthTokenValid();
        if (isTokenValid) {
          CacheLogger.debug('Using cached profile (auth token valid)');
          _refreshProfileInBackground();
          return cached;
        } else {
          CacheLogger.warning('Auth token invalid, bypassing cached profile');
          // Continue to fetch fresh profile
        }
      }
    }

    try {
      final dynamic profileData = await _apiClient.get('/profiles/me');
      final map = Map<String, dynamic>.from(profileData as Map);
      await CacheStore.instance.put(CacheKeys.profileMe, map);
      final appUser = _appUserFromProfile(map);
      _session.updateUser(appUser);
      return appUser;
    } on ApiException catch (e) {
      if (e.code == 'PROFILE_NOT_FOUND') {
        throw const AuthFailure(
          AuthFailureCode.profileNotFound,
          'Your account is confirmed, but your profile is not set up yet.',
        );
      }
      rethrow;
    }
  }

  /// Validates if the auth token is still active.
  Future<bool> _isAuthTokenValid() async {
    try {
      final session = _supabaseAuth.currentSession;
      if (session == null) {
        CacheLogger.debug('No active auth session');
        return false;
      }

      // Check if token is expired
      final expiresAt = session.expiresAt;
      if (expiresAt != null) {
        final isExpired = DateTime.now().isAfter(
          DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000),
        );
        if (isExpired) {
          CacheLogger.debug('Auth token expired');
          return false;
        }
      }

      CacheLogger.debug('Auth token is valid');
      return true;
    } catch (e) {
      CacheLogger.error('Error validating auth token', e);
      return false;
    }
  }

  void _refreshProfileInBackground() {
    getCurrentUser(forceRefresh: true).then((_) {
      CacheLogger.debug('Background profile refresh completed');
    }).catchError((Object error, StackTrace stackTrace) {
      CacheLogger.warning(
        'Background profile refresh failed (cache will be reused)',
      );
      // Don't crash the app; just log and continue with cached data
    });
  }

  Future<void> _persistProfile(Map<String, dynamic> map) async {
    await CacheStore.instance.put(CacheKeys.profileMe, map);
  }

  Future<AppUser> createProfile(Map<String, dynamic> body) async {
    try {
      final dynamic profileData = await _apiClient.post('/profiles', body: body);
      final map = Map<String, dynamic>.from(profileData as Map);
      await _persistProfile(map);
      final appUser = _appUserFromProfile(map);
      _session.updateUser(appUser);
      return appUser;
    } on ApiException catch (e) {
      if (e.code == 'PROFILE_EXISTS') {
        return getCurrentUser();
      }
      throw AuthFailure(
        AuthFailureCode.profileCreateFailed,
        e.message.isNotEmpty ? e.message : 'Could not create your profile.',
      );
    }
  }

  Future<AppUser> becomeWorker(Map<String, dynamic> body) async {
    try {
      final dynamic profileData =
          await _apiClient.post('/profiles/me/worker', body: body);
      final map = Map<String, dynamic>.from(profileData as Map);
      await _persistProfile(map);
      final appUser = _appUserFromProfile(map);
      _session.onboardAsWorker(appUser);
      return appUser;
    } on ApiException catch (e) {
      throw AuthFailure(
        AuthFailureCode.profileCreateFailed,
        e.message.isNotEmpty ? e.message : 'Could not set up your worker profile.',
      );
    }
  }

  Future<AppUser> updateActiveMode(String mode) async {
    final dynamic profileData = await _apiClient.patch(
      '/profiles/me/mode',
      body: <String, dynamic>{'mode': mode},
    );
    final map = Map<String, dynamic>.from(profileData as Map);
    await _persistProfile(map);
    final appUser = _appUserFromProfile(map);
    _session.updateUser(appUser);
    return appUser;
  }

  Future<void> resendVerificationEmail(String email) async {
    await _supabaseAuth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: AppConstants.supabaseRedirectUrl,
    );
  }

  Future<bool> tryRefreshSession() async {
    try {
      final AuthResponse? response = await _supabaseAuth.refreshSession();
      return response?.session != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseAuth.signOut();
    } catch (_) {
      // Ignore remote errors to ensure local session always clears
    } finally {
      _session.clear();
      await CacheStore.instance.clearOnSignOut();
    }
  }

  AppUser _appUserFromProfile(Map<String, dynamic> json) {
    final String? authEmail = _supabaseAuth.currentUser?.email;
    return AppUser.fromJson(<String, dynamic>{
      ...json,
      if (json['email'] == null && authEmail != null) 'email': authEmail,
    });
  }

  AuthFailure _mapAuthException(AuthException e, {bool forSignUp = false}) {
    final String msg = e.message.toLowerCase();
    final String? code = e.code?.toLowerCase();

    if (msg.contains('email not confirmed') ||
        code == 'email_not_confirmed') {
      return const AuthFailure(
        AuthFailureCode.emailNotConfirmed,
        'Please confirm your email using the link we sent before signing in.',
      );
    }

    if (forSignUp &&
        (msg.contains('already registered') ||
            msg.contains('user already exists'))) {
      return const AuthFailure(
        AuthFailureCode.accountAlreadyExists,
        'An account with this email already exists. Try signing in instead.',
      );
    }

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid email or password')) {
      return const AuthFailure(
        AuthFailureCode.invalidCredentials,
        'Incorrect email or password. If you just signed up, confirm your email first.',
      );
    }

    return AuthFailure(
      AuthFailureCode.unknown,
      e.message.isNotEmpty ? e.message : 'Authentication failed.',
    );
  }
}
