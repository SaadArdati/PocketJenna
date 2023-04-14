import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:universal_io/io.dart';

import '../../constants.dart';
import '../../models/chat.dart';
import '../../models/user_model.dart';
import '../auth/auth_manager.dart';
import 'firebase_data_manager.dart';
import 'firedart_data_manager.dart';

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
  Future<void> init() async {
    userBox = await Hive.openBox(Constants.user);
  }

  /// Dispose of any resources related to the data manager.
  /// This method should be called when the manager is no longer needed.
  @mustCallSuper
  void dispose() {}

  Stream<Chat?> getChatStream(String chatId);

  Future<Chat?> fetchChat(String chatId);

  Future<void> uploadChat(Chat chat) async {
    final String? token = await AuthManager.instance.getAuthToken();
    if (token == null) {
      throw Exception('No token');
    }
    await post(
      Uri.https(Constants.firebaseFunctionsBaseURL, '/widgets/updateChat'),
      body: json.encode(chat.toJson()),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<void> uploadIfNecessary(Chat chat) async {
    final String? token = await AuthManager.instance.getAuthToken();
    if (token == null) {
      throw Exception('No token');
    }

    final Response response = await get(
      Uri.https(
        Constants.firebaseFunctionsBaseURL,
        '/widgets/getChat',
        {'chatId': chat.id},
      ),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final Chat serverChat = Chat.fromJson(json);

      if (serverChat.updatedOn.isBefore(chat.updatedOn)) {
        await uploadChat(chat);
      }
    }
  }

  Future<void> registerUser() async {
    final String? token = await AuthManager.instance.getAuthToken();
    if (token == null) {
      throw Exception('No token: Authentication token is missing');
    }
    final response = await post(
      Uri.https(Constants.firebaseFunctionsBaseURL, '/widgets/registerUser'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      print('User registered');
      print(response.body);
    } else {
      throw Exception(
          'Registration failed: ${response.statusCode} ${response.body} ${response.reasonPhrase}');
    }
  }

  /// Get the openAI key from the server.
  Future<String> fetchOpenAIKey() async {
    final String? token = await AuthManager.instance.getAuthToken();
    if (token == null) {
      return '';
    }
    final response = await get(
      Uri.https(Constants.firebaseFunctionsBaseURL, '/widgets/getOpenAIKey'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'text/plain',
      },
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return '';
    }
  }

  void saveChat(Chat chat) {
    userBox.put(chat.id, chat.toJson());
  }
}
