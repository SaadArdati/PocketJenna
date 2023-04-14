import 'dart:async';

import 'package:universal_io/io.dart';

import '../../models/auth_model.dart';
import 'firebase_auth_manager.dart';
import 'firedart_auth_manager.dart';

/// The abstract class AuthManager defines the methods necessary to
/// manage user authentication in the application.
abstract class AuthManager {
  static AuthManager? _instance;

  static AuthManager get instance => _instance ??= AuthManager._();

  const AuthManager.internal();

  factory AuthManager._() {
    if (Platform.isWindows) {
      return FireDartAuthManager.internal();
    } else {
      return FirebaseAuthManager.internal();
    }
  }

  Stream<AuthModel?> get authStream;

  AuthModel? get currentAuth;

  bool get isAuthenticated => currentAuth != null;

  /// Initialize the authentication manager.
  /// This method should be called before using any of the other methods.
  Future<void> init();

  /// Dispose of any resources related to the authentication manager.
  /// This method should be called when the manager is no longer needed.
  void dispose();

  /// Get the current user's authentication token.
  Future<String?> getAuthToken();

  /// Sign-in the user with the provided email and password.
  /// Throws an error if the operation fails.
  Future<void> signIn(String email, String password);

  /// Sign-up the user with the provided email and password.
  /// Throws an error if the operation fails.
  Future<void> signUp(String email, String password);

  /// Send a password reset email to the user based on the provided email.
  /// Throws an error if the operation fails.
  Future<void> sendPasswordResetEmail(String email);

  /// Sign the user out.
  /// Throws an error if the operation fails.
  Future<void> signOut();

  Future<void> forgotPassword(String email);

  Future<void> deleteAccount();
}
