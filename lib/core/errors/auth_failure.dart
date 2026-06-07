enum AuthFailureCode {
  emailVerificationRequired,
  emailNotConfirmed,
  invalidCredentials,
  profileNotFound,
  profileCreateFailed,
  accountAlreadyExists,
  signUpFailed,
  network,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.code, this.message);

  final AuthFailureCode code;
  final String message;

  @override
  String toString() => message;
}

class SignUpOutcome {
  const SignUpOutcome._({
    required this.needsEmailVerification,
    required this.email,
    this.user,
  });

  final bool needsEmailVerification;
  final String email;
  final dynamic user;

  factory SignUpOutcome.needsVerification(String email) =>
      SignUpOutcome._(needsEmailVerification: true, email: email);

  factory SignUpOutcome.signedIn(String email, dynamic user) =>
      SignUpOutcome._(needsEmailVerification: false, email: email, user: user);
}
