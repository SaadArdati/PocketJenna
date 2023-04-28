import 'dart:async';

import 'package:dart_openai/openai.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/widgets.dart';

import '../../constants.dart';
import '../../models/auth_model.dart';
import '../../models/chat.dart';
import '../../models/prompt.dart';
import '../../models/user_model.dart';
import '../auth/auth_manager.dart';
import '../gpt_manager.dart';
import 'data_manager.dart';

class FireDartDataManager extends DataManager {
  final StreamController<UserModel?> _userStreamController =
      StreamController<UserModel?>.broadcast();

  UserModel? _currentUser;

  @override
  Stream<UserModel?> get userStream => _userStreamController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  StreamSubscription<Document?>? _firebaseStreamSubscription;
  late StreamSubscription<AuthModel?> _authStreamSubscription;
  late AuthModel? _authModel;

  FireDartDataManager.internal() : super.internal();

  @override
  Future<void> init() async {
    super.init();

    Firestore.initialize(Constants.firebaseProjectID);

    _authModel = AuthManager.instance.currentAuth;
    _authStreamSubscription = AuthManager.instance.authStream.listen(
      (AuthModel? authModel) {
        _authModel = authModel;
        if (_authModel == null) return;

        streamUser(authModel!, onEvent: (UserModel? user) {
          debugPrint('auth changed, user stream event. ${user?.id}');
          _currentUser = user;
          _userStreamController.add(user);

          if (user == null) {
            // registerUser();
          } else {
            fetchOpenAIKey().then((value) {
              OpenAI.apiKey = value;
              GPTManager.fetchAndStoreModels();
            });
          }
        });
      },
    );

    // Initial load with whatever auth model we currently have.
    final Completer<UserModel?> completer = Completer<UserModel?>();
    if (_authModel == null) {
      completer.complete();
    } else {
      streamUser(
        _authModel!,
        onEvent: (UserModel? user) async {
          debugPrint('initial load, user stream event. ${user?.id}');
          _currentUser = user;
          _userStreamController.add(user);

          if (user == null) {
            // registerUser();
          } else {
            OpenAI.apiKey = await fetchOpenAIKey();
            await GPTManager.fetchAndStoreModels();
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
    _firebaseStreamSubscription = Firestore.instance
        .collection(Constants.collectionUsers)
        .document(authModel.id)
        .stream
        .listen((Document? event) {
      if (event == null || event.map.isEmpty) {
        onEvent?.call(null);
        return;
      }

      try {
        final user = UserModel.fromJson(event.map);
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

    return Firestore.instance
        .collection(Constants.collectionUsers)
        .document(AuthManager.instance.currentAuth!.id)
        .collection(Constants.collectionChats)
        .document(chatId)
        .stream
        .map((event) => Chat.fromJson(event!.map));
  }

  @override
  Future<Chat?> fetchChat(String chatId) async {
    assert(
      AuthManager.instance.currentAuth != null,
      'Chat streaming should never be allowed when auth is not ready',
    );

    final DocumentReference docRef = Firestore.instance
        .collection(Constants.collectionUsers)
        .document(AuthManager.instance.currentAuth!.id)
        .collection(Constants.collectionChats)
        .document(chatId);

    if (!await docRef.exists) {
      return null;
    }

    final Document doc = await docRef.get();
    final Map<String, dynamic> data = doc.map;

    return Chat.fromJson(data);
  }

  @override
  Future<List<Prompt>> fetchMarket(int page, int pageSize) {
    return Firestore.instance
        .collection(Constants.collectionMarket)
        .orderBy('upvotes', descending: true)
        .limit(pageSize)
        .get()
        .then(
          (List<Document> value) =>
              value.map((e) => Prompt.fromJson(e.map)).toList(),
        );
  }
}
