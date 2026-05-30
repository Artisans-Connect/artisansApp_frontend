import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/auth_failure.dart';
import '../network/api_client.dart';
import '../session/app_user_session.dart';

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

      return await getCurrentUser();
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

  Future<AppUser> getCurrentUser() async {
    try {
      final dynamic profileData = await _apiClient.get('/profiles/me');
      final appUser = _appUserFromProfile(profileData as Map<String, dynamic>);
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

  Future<AppUser> createProfile(Map<String, dynamic> body) async {
    try {
      final dynamic profileData = await _apiClient.post('/profiles', body: body);
      final appUser = _appUserFromProfile(profileData as Map<String, dynamic>);
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

  Future<void> resendVerificationEmail(String email) async {
    await _supabaseAuth.resend(type: OtpType.signup, email: email);
  }

  Future<void> signOut() async {
    await _supabaseAuth.signOut();
    _session.clear();
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
