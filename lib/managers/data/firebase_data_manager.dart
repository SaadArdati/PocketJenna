import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter/cupertino.dart';

import '../../constants.dart';
import '../../models/auth_model.dart';
import '../../models/chat.dart';
import '../../models/prompt.dart';
import '../../models/user_model.dart';
import '../auth/auth_manager.dart';
import '../gpt_manager.dart';
import '../prompt_manager.dart';
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

  bool _didFetchOpenAIKey = false;

  FirebaseDataManager.internal() : super.internal();

  @override
  Future<void> init() async {
    super.init();

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
            if (!_didFetchOpenAIKey) {
              _didFetchOpenAIKey = true;
              fetchOpenAIKey().then((value) {
                OpenAI.apiKey = value;
                GPTManager.fetchAndStoreModels();
              }).catchError((error) {
                debugPrint('error fetching openai key: $error');
                _didFetchOpenAIKey = false;
              });
            }

            fetchPrompts(promptIDs: user.pinnedPrompts).then(
              (prompts) => PromptManager.instance.registerPrompts(prompts),
            );
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
            if (!_didFetchOpenAIKey) {
              _didFetchOpenAIKey = true;
              try {
                OpenAI.apiKey = await fetchOpenAIKey();
                await GPTManager.fetchAndStoreModels();
                _didFetchOpenAIKey = true;
              } catch (error) {
                debugPrint('error fetching openai key: $error');
                _didFetchOpenAIKey = false;
              }
            }

            fetchPrompts(promptIDs: user.pinnedPrompts).then(
              (prompts) => PromptManager.instance.registerPrompts(prompts),
            );
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
    final userDoc = FirebaseFirestore.instance
        .collection(Constants.collectionUsers)
        .doc(authModel.id);
    userDoc.get().then((userSnapshot) {
      if (!userSnapshot.exists) {
        registerUser();
      }
    });
    _firebaseStreamSubscription?.cancel();
    _firebaseStreamSubscription = userDoc
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> event) {
      final Map<String, dynamic>? data = event.data();
      if (!event.exists || data == null || data.isEmpty) {
        debugPrint('User model is null or data is empty.');
        onEvent?.call(null);
        return;
      }
      try {
        debugPrint('User model event received');
        final user = UserModel.fromJson(data);
        onEvent?.call(user);
      } catch (e, str) {
        onEvent?.call(null);
        debugPrintStack(label: '$e', stackTrace: str);
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

  @override
  Future<List<Prompt>> fetchMarket(int page, int pageSize) {
    return FirebaseFirestore.instance
        .collection(Constants.collectionMarket)
        .orderBy('upvotes', descending: true)
        .limit(pageSize)
        .get()
        .then(
          (value) => value.docs.map((e) => Prompt.fromJson(e.data())).toList(),
        );
  }
}
