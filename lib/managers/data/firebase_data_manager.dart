import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants.dart';
import '../auth/auth_model.dart';
import '../../models/chat.dart';
import 'data_manager.dart';
import 'user_model.dart';

class FirebaseDataManager extends DataManager {
  final StreamController<UserModel?> _userStreamController =
      StreamController<UserModel?>.broadcast();

  UserModel? _currentUser;
  late AuthModel _authModel;

  @override
  Stream<UserModel?> get userStream => _userStreamController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  FirebaseDataManager.internal() : super.internal();

  @override
  Future<void> init(AuthModel authModel) async {
    super.init(authModel);
    _authModel = authModel;

    final Completer<UserModel?> completer = Completer<UserModel?>();
    FirebaseFirestore.instance
        .collection(Constants.collectionUsers)
        .doc(authModel.id)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> event) {
      _currentUser = UserModel.fromJson(event.data()!);
      _userStreamController.add(_currentUser);

      if (!completer.isCompleted) {
        completer.complete(_currentUser);
      }
    });

    await completer.future;
  }

  @override
  void dispose() {
    _userStreamController.close();
  }

  @override
  Stream<Chat?> getChatStream(String chatId) {
    return FirebaseFirestore.instance
        .collection(Constants.collectionUsers)
        .doc(_authModel.id)
        .collection(Constants.collectionChatHistory)
        .doc(chatId)
        .snapshots()
        .map((event) => Chat.fromJson(event.data()!));
  }
}
