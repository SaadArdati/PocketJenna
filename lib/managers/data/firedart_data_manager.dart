import 'dart:async';

import 'package:firedart/firedart.dart';

import '../../constants.dart';
import '../auth/auth_manager.dart';
import '../auth/auth_model.dart';
import '../../models/chat.dart';
import 'data_manager.dart';
import 'user_model.dart';

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

    _authModel = AuthManager.instance.currentAuth;
    _authStreamSubscription = AuthManager.instance.authStream.listen(
      (AuthModel? authModel) {
        _authModel = authModel;
        if (_authModel == null) return;
        streamUser(authModel!, onEvent: (UserModel? user) {
          _currentUser = user;
          _userStreamController.add(user);
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
        onEvent: (UserModel? user) {
          _currentUser = user;
          _userStreamController.add(user);
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
      if (event == null) {
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
        .collection(Constants.collectionChatHistory)
        .document(chatId)
        .stream
        .map((event) => Chat.fromJson(event!.map));
  }
}
