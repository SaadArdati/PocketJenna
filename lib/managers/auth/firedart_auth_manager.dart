import 'dart:async';

import 'package:firedart/auth/user_gateway.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import '../../constants.dart';
import '../../models/auth_model.dart';
import 'auth_manager.dart';

class HiveStore extends TokenStore {
  final Box _tokenBox;

  AuthModel? user;

  HiveStore(this._tokenBox);

  @override
  Token? read() {
    try {
      final Map<String, dynamic>? userJson =
          _tokenBox.get(Constants.userModel)?.cast<String, dynamic>();
      if (userJson != null) {
        user = AuthModel.fromJson(userJson);
      }

      final Map<String, dynamic>? tokenJson =
          _tokenBox.get(Constants.authToken)?.cast<String, dynamic>();

      if (tokenJson == null || tokenJson.isEmpty) return null;

      return Token.fromMap(tokenJson);
    } catch (ex, str) {
      debugPrintStack(label: ex.toString(), stackTrace: str);
      return null;
    }
  }

  @override
  void write(Token? token) {
    _tokenBox.clear();
    if (token != null) {
      _tokenBox.put(Constants.authToken, token.toMap());
    } else {
      _tokenBox.delete(Constants.authToken);
    }
    if (user != null) {
      _tokenBox.put(Constants.userModel, user!.toJson());
    } else {
      _tokenBox.delete(Constants.userModel);
    }
  }

  void saveUser(AuthModel? user) {
    if (user != null) {
      _tokenBox.put(Constants.userModel, user.toJson());
    } else {
      _tokenBox.delete(Constants.userModel);
    }
  }

  @override
  void delete() {
    _tokenBox.clear();
    user = null;
  }
}

class FireDartAuthManager extends AuthManager {
  final StreamController<AuthModel?> _userStreamController =
      StreamController<AuthModel?>.broadcast();

  late final HiveStore store;

  AuthModel? _currentUser;

  @override
  AuthModel? get currentAuth => _currentUser;

  @override
  Stream<AuthModel?> get authStream => _userStreamController.stream;

  FireDartAuthManager.internal() : super.internal();

  @override
  Future<void> init() async {
    // Open a box for storing tokens
    // TODO: Encryption
    final tokenBox = await Hive.openBox(Constants.auth);

    store = HiveStore(tokenBox);

    FirebaseAuth.initialize(
      Constants.firebaseWebAPIKey,
      store,
    );

    _currentUser = store.user;
    _userStreamController.add(_currentUser);
  }

  @override
  void dispose() {
    _userStreamController.close();
  }

  void _fireDartUserToModel(User? user) {
    if (user == null) {
      _currentUser = null;
    } else {
      _currentUser = AuthModel(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
      );
    }
    store.saveUser(_currentUser);
    _userStreamController.add(_currentUser);
  }

  @override
  Future<String> getAuthToken() async =>
      FirebaseAuth.instance.tokenProvider.idToken.catchError(
        (e) => throw Exception('No token: Authentication token is missing'),
      );

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      FirebaseAuth.instance.resetPassword(email);

  @override
  Future<void> signIn(String email, String password) async {
    final User user = await FirebaseAuth.instance.signIn(email, password);
    _fireDartUserToModel(user);
  }

  @override
  Future<void> signUp(
    String email,
    String password, {
    FutureCallback? onSignUp,
  }) async {
    final User user = await FirebaseAuth.instance.signUp(email, password);

    await onSignUp?.call();

    _fireDartUserToModel(user);
  }

  @override
  Future<void> signOut() async => FirebaseAuth.instance.signOut();

  @override
  Future<void> forgotPassword(String email) async {
    await FirebaseAuth.instance.resetPassword(email);
  }

  @override
  Future<void> deleteAccount() async {
    await FirebaseAuth.instance.deleteAccount();
  }
}
