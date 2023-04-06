import 'dart:async';

import 'package:firedart/auth/user_gateway.dart';
import 'package:firedart/firedart.dart';
import 'package:hive/hive.dart';

import '../../constants.dart';
import 'auth_manager.dart';
import 'auth_model.dart';

class HiveStore extends TokenStore {
  final Box _tokenBox;

  AuthModel? user;

  HiveStore(this._tokenBox);

  @override
  Token? read() {
    final Map<String, dynamic>? userJson = _tokenBox.get(
      Constants.userModel,
      defaultValue: null,
    );
    if (userJson != null) {
      user = AuthModel.fromJson(userJson);
    }

    final tokenJson = _tokenBox.get(Constants.authToken, defaultValue: null);

    if (tokenJson == null) return null;

    return Token.fromMap(tokenJson);
  }

  @override
  void write(Token? token) {
    _tokenBox.clear();
    if (token != null) {
      _tokenBox.add(token);
    }
    if (user != null) {
      _tokenBox.add(user);
    }
  }

  @override
  void delete() {
    _tokenBox.clear();
  }
}

class FireDartAuthManager extends AuthManager {
  final StreamController<AuthModel?> _userStreamController =
      StreamController<AuthModel?>.broadcast();

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
    final tokenBox = await Hive.openBox<Map<String, dynamic>>(Constants.auth);

    final HiveStore store = HiveStore(tokenBox);

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

  @override
  Future<String> getAuthToken() async =>
      FirebaseAuth.instance.tokenProvider.idToken;

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      FirebaseAuth.instance.resetPassword(email);

  @override
  Future<void> signIn(String email, String password) async {
    final User user = await FirebaseAuth.instance.signIn(email, password);
    _fireDartUserToModel(user);
  }

  @override
  Future<void> signUp(String email, String password) async {
    final User user = await FirebaseAuth.instance.signUp(email, password);
    _fireDartUserToModel(user);
  }

  @override
  Future<void> signOut() async => FirebaseAuth.instance.signOut();

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
    _userStreamController.add(_currentUser);
  }
}
