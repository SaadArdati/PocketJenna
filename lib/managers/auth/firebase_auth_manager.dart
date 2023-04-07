import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import '../../firebase_options.dart';
import 'auth_manager.dart';
import 'auth_model.dart';

class FirebaseAuthManager extends AuthManager {
  final StreamController<AuthModel?> _userStreamController =
      StreamController<AuthModel?>.broadcast();

  AuthModel? _currentUser;

  @override
  AuthModel? get currentAuth => _currentUser;

  @override
  Stream<AuthModel?> get authStream => _userStreamController.stream;

  StreamSubscription<User?>? _userChangesSubscription;

  FirebaseAuthManager.internal() : super.internal();

  @override
  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    final Completer<AuthModel?> completer = Completer<AuthModel?>();
    _userChangesSubscription =
        FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        debugPrint('User is currently signed out!');
      } else {
        debugPrint('User is signed in!');
      }

      _firebaseUserToModel(user);

      if (!completer.isCompleted) {
        completer.complete(_currentUser);
      }
    });

    await completer.future;
    // _firebaseUserToModel(await FirebaseAuth.instance.userChanges().first);
  }

  void _firebaseUserToModel(User? user) {
    if (user == null) {
      _currentUser = null;
    } else {
      _currentUser = AuthModel(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
    }
    _userStreamController.add(_currentUser);
  }

  @override
  void dispose() {
    _userChangesSubscription?.cancel();
    _userStreamController.close();
  }

  @override
  Future<String> getAuthToken() async =>
      FirebaseAuth.instance.currentUser!.getIdToken();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);

  @override
  Future<void> signIn(String email, String password) async {
    final UserCredential userCredentials =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    _firebaseUserToModel(userCredentials.user);
  }

  @override
  Future<void> signUp(String email, String password) async {
    final UserCredential userCredentials =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    _firebaseUserToModel(userCredentials.user);
  }

  @override
  Future<void> signOut() async => FirebaseAuth.instance.signOut;

  @override
  Future<void> forgotPassword(String email) async => FirebaseAuth.instance.sendPasswordResetEmail(email: email);

  @override
  Future<void> deleteAccount() async => FirebaseAuth.instance.currentUser!.delete();
}
