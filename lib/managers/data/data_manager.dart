import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:universal_io/io.dart';

import '../../constants.dart';
import '../auth/auth_manager.dart';
import '../auth/auth_model.dart';
import '../../models/chat.dart';
import 'firebase_data_manager.dart';
import 'firedart_data_manager.dart';
import 'user_model.dart';

abstract class DataManager {
  static DataManager? _instance;

  static DataManager get instance => _instance ??= DataManager._();

  DataManager.internal();

  factory DataManager._() {
    if (Platform.isWindows) {
      return FireDartDataManager.internal();
    } else {
      return FirebaseDataManager.internal();
    }
  }

  Stream<UserModel?> get userStream;

  UserModel? get currentUser;

  late Box userBox;

  /// Initialize the data manager.
  /// This method should be called before using any of the other methods.
  @mustCallSuper
  Future<void> init(AuthModel authModel) async {
    userBox = await Hive.openBox(Constants.user);
  }

  /// Dispose of any resources related to the data manager.
  /// This method should be called when the manager is no longer needed.
  void dispose();

  Stream<Chat?> getChatStream(String chatId);

  Future<void> uploadChat(Chat chat) async {
    final String? token = await AuthManager.instance.getAuthToken();
    if (token == null) {
      throw Exception('No token');
    }
    post(
      Uri.parse('${Constants.firebaseFunctionsBaseURL}/updateChat'),
      body: {'chat': chat.toJson()},
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> uploadIfNecessary(Chat chat) async {
    final String? token = await AuthManager.instance.getAuthToken();
    if (token == null) {
      throw Exception('No token');
    }

    final Response response = await get(
      Uri.parse('${Constants.firebaseFunctionsBaseURL}/getChat')
        ..queryParameters['chatId'] = chat.id,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final Chat serverChat = Chat.fromJson(json);

      if (serverChat.updatedOn.isBefore(chat.updatedOn)) {
        await uploadChat(chat);
      }
    }
  }

  void saveChat(Chat chat) {
    userBox.put(chat.id, chat.toJson());
  }
}
