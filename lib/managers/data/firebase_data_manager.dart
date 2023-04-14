import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/openai.dart';

import '../../constants.dart';
import '../../models/auth_model.dart';
import '../../models/chat.dart';
import '../../models/user_model.dart';
import '../auth/auth_manager.dart';
import 'data_manager.dart';

class FirebaseDataManager extends DataManager {
  final StreamController<UserModel?> _userStreamController =
  StreamController<UserModel?>.broadcast();

  UserModel? _currentUser;

  @override
  Stream<UserModel?> get userStream => _userStreamController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  StreamSubscription<DocumentSnapshot>? _firebaseStreamSubscription;
  late StreamSubscription<AuthModel?> _authStreamSubscription;
  late AuthModel? _authModel;

  FirebaseDataManager.internal() : super.internal();

  @override
  Future<void> init() async {
    super.init();

    _authModel = AuthManager.instance.currentAuth;
    _authStreamSubscription = AuthManager.instance.authStream.listen(
          (AuthModel? authModel) {
        _authModel = authModel;
        if (_authModel == null) return;

        fetchOpenAIKey().then((value) => OpenAI.apiKey = value);
        streamUser(authModel!, onEvent: (UserModel? user) {
          print('auth changed, user stream event. ${user?.id}');
          _currentUser = user;
          _userStreamController.add(user);

          if (user == null) {
            registerUser();
          }
        });
      },
    );

    // Initial load with whatever auth model we currently have.
    final Completer<UserModel?> completer = Completer<UserModel?>();
    if (_authModel == null) {
      completer.complete();
    } else {
      OpenAI.apiKey = await fetchOpenAIKey();
      streamUser(
        _authModel!,
        onEvent: (UserModel? user) {
          print('initial load, user stream event. ${user?.id}');
          _currentUser = user;
          _userStreamController.add(user);

          if (user == null) {
            registerUser();
          }

          if (!completer.isCompleted) {
            completer.complete(user);
          }
        },
      );
    }

    await completer.future;
  }

  @override
  void dispose() {
    _userStreamController.close();
    _firebaseStreamSubscription?.cancel();
    _authStreamSubscription.cancel();
    super.dispose();
  }

  void streamUser(AuthModel authModel, {Function(UserModel?)? onEvent}) {
    _firebaseStreamSubscription?.cancel();
    _firebaseStreamSubscription = FirebaseFirestore.instance
        .collection(Constants.collectionUsers)
        .doc(authModel.id)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> event) {
      final Map<String, dynamic>? data = event.data();
      if (!event.exists || data == null || data.isEmpty) {
        onEvent?.call(null);
        return;
      }
      try {
        final user = UserModel.fromJson(data);
        onEvent?.call(user);
      } catch (e) {
        onEvent?.call(null);
        rethrow;
      }
    });
  }

  @override
  Stream<Chat?> getChatStream(String chatId) {
    assert(
    AuthManager.instance.currentAuth != null,
    'Chat streaming should never be allowed when auth is not ready',
    );

    return FirebaseFirestore.instance
        .collection(Constants.collectionUsers)
        .doc(AuthManager.instance.currentAuth!.id)
        .collection(Constants.collectionChats)
        .doc(chatId)
        .snapshots()
        .map((event) => Chat.fromJson(event.data()!));
  }

  @override
  Future<Chat?> fetchChat(String chatId) async {
    assert(
    AuthManager.instance.currentAuth != null,
    'Chat streaming should never be allowed when auth is not ready',
    );

    final snapshot = await FirebaseFirestore.instance
        .collection(Constants.collectionUsers)
        .doc(AuthManager.instance.currentAuth!.id)
        .collection(Constants.collectionChats)
        .doc(chatId)
        .get();

    if (!snapshot.exists) return null;

    final Map<String, dynamic>? data = snapshot.data();

    return data == null ? null : Chat.fromJson(data);
  }
}
