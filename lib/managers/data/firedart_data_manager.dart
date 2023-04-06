import 'dart:async';

import 'package:firedart/firedart.dart';

import '../../constants.dart';
import '../auth/auth_model.dart';
import '../../models/chat.dart';
import 'data_manager.dart';
import 'user_model.dart';

class FireDartDataManager extends DataManager {
  final StreamController<UserModel?> _userStreamController =
      StreamController<UserModel?>.broadcast();

  UserModel? _currentUser;
  late AuthModel _authModel;

  @override
  Stream<UserModel?> get userStream => _userStreamController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  FireDartDataManager.internal() : super.internal();

  @override
  Future<void> init(AuthModel authModel) async {
    super.init(authModel);
    _authModel = authModel;

    final Completer<UserModel?> completer = Completer<UserModel?>();
    Firestore.instance
        .collection(Constants.collectionUsers)
        .document(authModel.id)
        .stream
        .listen((Document? event) {
      _currentUser = UserModel.fromJson(event!.map);
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
    return Firestore.instance
        .collection(Constants.collectionUsers)
        .document(_authModel.id)
        .collection(Constants.collectionChatHistory)
        .document(chatId)
        .stream
        .map((event) => Chat.fromJson(event!.map));
  }
}
