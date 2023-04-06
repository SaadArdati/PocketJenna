class AuthException implements Exception {
  final String? message;

  AuthException({this.message});
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException({super.message});
}