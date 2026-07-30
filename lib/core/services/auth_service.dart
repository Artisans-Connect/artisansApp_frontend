import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../cache/cache_keys.dart';
import '../cache/cache_store.dart';
import '../constants/app_constants.dart';
import '../errors/auth_failure.dart';
import '../location/worker_location_service.dart';
import '../network/api_client.dart';
import '../session/app_user_session.dart';
import '../utils/cache_logger.dart';
import 'notification_service.dart';

enum GoogleAuthFlow {
  signIn,
  signUp,
}

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final _supabaseAuth = Supabase.instance.client.auth;
  final _apiClient = ApiClient.instance;
  final _session = AppUserSession.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _googleSignInInit;

  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
    String? phone,
    String? fullName,
  }) async {
    try {
      final AuthResponse response = await _supabaseAuth.signUp(
        email: email,
        password: password,
        emailRedirectTo: AppConstants.supabaseRedirectUrl,
        data: <String, dynamic>{
          if (phone != null) 'phone': phone,
          if (fullName != null) 'full_name': fullName,
        },
      );

      if (response.user == null) {
        throw const AuthFailure(
          AuthFailureCode.signUpFailed,
          'Sign up failed. Please try again.',
        );
      }

      if (response.user!.identities != null && response.user!.identities!.isEmpty) {
        throw const AuthFailure(
          AuthFailureCode.accountAlreadyExists,
          'An account with this email already exists. Try signing in instead.',
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
      if (e.code == 'ACCOUNT_SUSPENDED') {
        await signOut();
        throw const AuthFailure(
          AuthFailureCode.accountSuspended,
          'Your account has been suspended. Please contact admin/support if you think this is a mistake.',
        );
      }
      if (e.code == 'PROFILE_NOT_FOUND') {
        throw const AuthFailure(
          AuthFailureCode.profileNotFound,
          'Your account is confirmed, but your profile is not set up yet.',
        );
      }
      rethrow;
    }
  }

  Future<AppUser> signInWithGoogle({
    GoogleAuthFlow flow = GoogleAuthFlow.signIn,
  }) async {
    try {
      if (kIsWeb) {
        // On Web, use Supabase OAuth redirection. This is 100% reliable,
        // bypasses browser popup blockers, and avoids client-side GIS SDK issues.
        //
        // 'prompt: select_account' forces Google to always show the account
        // picker even when only one account is signed in.
        await _supabaseAuth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: Uri.base.origin,
          queryParams: <String, String>{
            'prompt': 'select_account',
          },
        );
        // Return a future that never completes because the page is redirecting
        return Completer<AppUser>().future;
      }

      await _ensureGoogleSignInInitialized();
      await _googleSignIn.signOut();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final String? idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        throw const AuthFailure(
          AuthFailureCode.unknown,
          'Google sign in failed. No ID token received.',
        );
      }

      await _supabaseAuth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      return await getCurrentUser(forceRefresh: true);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure(
          AuthFailureCode.unknown,
          'Google sign in was cancelled.',
        );
      }
      throw AuthFailure(
        AuthFailureCode.unknown,
        e.description ?? 'Google sign in failed.',
      );
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } on ApiException catch (e) {
      if (e.code == 'PROFILE_NOT_FOUND') {
        final String message = flow == GoogleAuthFlow.signUp
            ? 'Your Google account is validated, but your profile needs to be set up.'
            : 'Your Google account is connected, but your profile is not set up yet.';
        throw AuthFailure(
          AuthFailureCode.profileNotFound,
          message,
        );
      }
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabaseAuth.resetPasswordForEmail(
        email,
        redirectTo: AppConstants.supabasePasswordResetRedirectUrl,
      );
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabaseAuth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw _mapAuthException(e);
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
      unawaited(NotificationService.instance.registerCurrentDevice());
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
    }).catchError((Object _, StackTrace __) {
      CacheLogger.warning(
        'Background profile refresh failed (cache will be reused)',
      );
    });
  }

  Future<void> _persistProfile(Map<String, dynamic> map) async {
    await CacheStore.instance.put(CacheKeys.profileMe, map);
  }

  Future<AppUser> createProfile(Map<String, dynamic> body) async {
    try {
      final dynamic profileData =
          await _apiClient.post('/profiles', body: body);
      final map = Map<String, dynamic>.from(profileData as Map);
      await _persistProfile(map);
      final appUser = _appUserFromProfile(map);
      _session.updateUser(appUser);
      unawaited(NotificationService.instance.registerCurrentDevice());
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
        e.message.isNotEmpty
            ? e.message
            : 'Could not set up your worker profile.',
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
    unawaited(NotificationService.instance.registerCurrentDevice());
    if (mode == 'client') {
      try {
        await _apiClient.put('/workers/availability', body: {'is_available': false});
      } catch (_) {}
    }
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
    // Capture mode before clearing so we know if worker cleanup is needed.
    final String activeMode = _session.activeMode;

    // ── 1. Clear local state FIRST so the UI responds instantly ──────────
    await WorkerLocationService.instance.stop();
    _session.clear();
    await CacheStore.instance.clearOnSignOut();

    // ── 2. Fire remote cleanup with a short timeout ─────────────────────
    //    These are best-effort; the user is already signed out locally.
    const Duration remoteTimeout = Duration(seconds: 5);

    await Future.wait<void>(<Future<void>>[
      // Mark worker offline
      if (activeMode == 'worker')
        _apiClient
            .put('/workers/availability', body: {'is_available': false})
            .timeout(remoteTimeout)
            .catchError((_) {}),

      // Unregister push token
      NotificationService.instance
          .unregisterCurrentDevice()
          .timeout(remoteTimeout)
          .catchError((_) {}),

      // Remote auth sign-out (Supabase + Google)
      Future<void>(() async {
        try {
          await _supabaseAuth.signOut().timeout(remoteTimeout);
        } catch (_) {}
        try {
          await _googleSignIn.signOut().timeout(remoteTimeout);
        } catch (_) {}
      }),
    ]);
  }

  Future<void> deleteAccount() async {
    const Duration remoteTimeout = Duration(seconds: 10);

    // ── 1. Best-effort: mark worker offline ─────────────────────────────
    if (_session.activeMode == 'worker') {
      try {
        await _apiClient
            .put('/workers/availability', body: {'is_available': false})
            .timeout(remoteTimeout);
      } catch (_) {}
    }

    // ── 2. Best-effort: delete profile on backend ───────────────────────
    try {
      await _apiClient.delete('/profiles/me').timeout(remoteTimeout);
    } catch (_) {
      // If the backend is sleeping or unreachable, still clear locally.
      // The backend can clean up orphaned auth users separately.
    }

    // ── 3. Always clear local state ─────────────────────────────────────
    await WorkerLocationService.instance.stop();
    _session.clear();
    await CacheStore.instance.clearOnSignOut();

    // ── 4. Best-effort: remote auth sign-out ────────────────────────────
    try {
      await _supabaseAuth.signOut().timeout(remoteTimeout);
    } catch (_) {}
    try {
      await _googleSignIn.signOut().timeout(remoteTimeout);
    } catch (_) {}
  }

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInit ??= _googleSignIn.initialize(
      clientId:
          '35491862087-v8st1cmcd1ulv8t0mv2762osp981s47m.apps.googleusercontent.com',
      serverClientId:
          '35491862087-v8st1cmcd1ulv8t0mv2762osp981s47m.apps.googleusercontent.com',
    );
  }

  Future<void> preInitializeGoogleSignIn() async {
    try {
      await _ensureGoogleSignInInitialized();
    } catch (e) {
      CacheLogger.error('Failed to pre-initialize Google Sign-In', e);
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

    if (_looksLikeNetworkError(msg)) {
      return const AuthFailure(
        AuthFailureCode.network,
        'Connection problem. Check your internet and try again.',
      );
    }

    if (msg.contains('email not confirmed') || code == 'email_not_confirmed') {
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

  bool _looksLikeNetworkError(String msg) {
    return msg.contains('socketexception') ||
        msg.contains('clientexception') ||
        msg.contains('failed host lookup') ||
        msg.contains('connection refused') ||
        msg.contains('connection reset') ||
        msg.contains('connection closed') ||
        msg.contains('network is unreachable') ||
        msg.contains('software caused connection abort') ||
        msg.contains('operation timed out') ||
        msg.contains('timed out') ||
        msg.contains('xmlhttprequest error') ||
        msg.contains('failed to fetch');
  }
}
