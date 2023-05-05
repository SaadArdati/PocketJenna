import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:universal_io/io.dart';

import '../../constants.dart';
import '../../models/chat.dart';
import '../../models/prompt.dart';
import '../../models/user_model.dart';
import '../auth/auth_manager.dart';
import '../prompt_manager.dart';
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
    final String token = await AuthManager.instance.getAuthToken();
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
    debugPrint('Uploading chat because it is necessary');
    final String token = await AuthManager.instance.getAuthToken();

    final Response response = await get(
      Uri.https(
        Constants.firebaseFunctionsBaseURL,
        '/widgets/updateChat',
        {'chatID': chat.id},
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final Chat serverChat = Chat.fromJson(json);

      if (serverChat.updatedOn.isBefore(chat.updatedOn)) {
        await uploadChat(chat);
        debugPrint('Uploaded necessary chat ${chat.id}');
      }
    } else {
      debugPrint(
          'Error updating chats when necessary: ${response.statusCode} ${response.body} ${response.reasonPhrase}');
    }
  }

  /// Get the openAI key from the server.
  Future<String> fetchOpenAIKey() async {
    final String token = await AuthManager.instance.getAuthToken();

    final response = await get(
      Uri.https(Constants.firebaseFunctionsBaseURL, '/widgets/getOpenAIKey'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'text/plain',
      },
    );
    if (response.statusCode == 200) {
      debugPrint('OpenAI key fetched: ${response.body}');
      return response.body;
    } else {
      throw Exception(
          'OpenAI key fetch failed: ${response.statusCode} ${response.body} ${response.reasonPhrase}');
    }
  }

  void saveChat(Chat chat) {
    userBox.put(chat.id, chat.toJson());
  }

  Future<List<Prompt>> fetchMarket(int page, int pageSize);

  Future<Set<Prompt>> fetchPrompts({
    required List<String> promptIDs,
  }) async {
    debugPrint('Getting prompts [${promptIDs.join(', ')}]...');
    final String token = await AuthManager.instance.getAuthToken();

    final response = await post(
      Uri.https(Constants.firebaseFunctionsBaseURL, '/widgets/getPrompts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'promptIDs': promptIDs,
      }),
    );
    if (response.statusCode == 200) {
      debugPrint('Prompts fetched successfully, deserializing...');
      final json = jsonDecode(response.body);
      final Set<Prompt> prompts = {
        ...json.map(
          (prompt) =>
              Prompt.fromJson(prompt..['upvotes'] = prompt['upvotes'].length),
        ),
      };

      debugPrint('${prompts.length} prompts fetched');
      return prompts;
    } else {
      throw Exception(
          'Failed to fetch prompts: ${response.statusCode} ${response.body} ${response.reasonPhrase}');
    }
  }

  Future<void> uploadPrompt({
    required List<String> prompts,
    required String title,
    required String icon,
    String? description,
    bool public = false,
  }) async {
    debugPrint('Setting prompt [${AuthManager.instance.currentAuth!.id}]...');
    final String token = await AuthManager.instance.getAuthToken();

    final response = await post(
      Uri.https(Constants.firebaseFunctionsBaseURL, '/widgets/setPrompt'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompts': prompts,
        'promptTitle': title,
        'promptIcon': icon,
        'promptDescription': description,
        'isPublic': public,
      }),
    );
    if (response.statusCode == 200) {
      debugPrint('Prompt uploaded');
      debugPrint(response.body);
      final id = jsonDecode(response.body)['id'];
      debugPrint('Prompt ID: $id');
    } else {
      throw Exception(
          'Prompt upload failed: ${response.statusCode} ${response.body} ${response.reasonPhrase}');
    }
  }

  Future<void> deletePrompt(Prompt prompt) async {
    debugPrint('Deleting prompt [${AuthManager.instance.currentAuth!.id}]...');
    final String token = await AuthManager.instance.getAuthToken();

    final response = await post(
      Uri.https(Constants.firebaseFunctionsBaseURL, '/widgets/deletePrompt'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'promptID': prompt.id}),
    );
    if (response.statusCode == 200) {
      debugPrint('Prompt deleted');
      debugPrint(response.body);
    } else {
      throw Exception(
          'Prompt deletion failed: ${response.statusCode} ${response.body} ${response.reasonPhrase}');
    }
  }

  Future<void> updatePinnedPrompts() async {
    debugPrint('Pinning prompt [${AuthManager.instance.currentAuth!.id}]...');
    assert(currentUser != null, 'No current user');

    final String token = await AuthManager.instance.getAuthToken();

    final response = await post(
      Uri.https(
          Constants.firebaseFunctionsBaseURL, '/widgets/updatePinnedPrompts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pinnedPrompts': [
          ...currentUser!.pinnedPrompts.map(
            (promptID) =>
                PromptManager.instance.getPromptByID(promptID)!.toJson(),
          )
        ],
      }),
    );
    if (response.statusCode == 200) {
      debugPrint('Pinned prompts updated');
      debugPrint(response.body);
    } else {
      throw Exception(
          'Pinned prompts update failed: ${response.statusCode} ${response.body} ${response.reasonPhrase}');
    }
  }

  Future<void> upvotePrompt({required String promptID}) async {
    debugPrint('Upvoting prompt [${AuthManager.instance.currentAuth!.id}]...');

    final String token = await AuthManager.instance.getAuthToken();

    final response = await post(
      Uri.https(Constants.firebaseFunctionsBaseURL, '/widgets/upvotePrompt'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'promptID': promptID}),
    );
    if (response.statusCode == 200) {
      debugPrint('Prompt upvoted');
      debugPrint(response.body);
    } else {
      throw Exception(
          'Prompt upvote failed: ${response.statusCode} ${response.body} ${response.reasonPhrase}');
    }
  }

  Future<void> unUpvotePrompt({required String promptID}) async {
    debugPrint('Upvoting prompt [${AuthManager.instance.currentAuth!.id}]...');

    final String token = await AuthManager.instance.getAuthToken();

    final response = await post(
      Uri.https(Constants.firebaseFunctionsBaseURL, '/widgets/unUpvotePrompt'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'promptID': promptID}),
    );
    if (response.statusCode == 200) {
      debugPrint('Prompt unUpvoted');
      debugPrint(response.body);
    } else {
      throw Exception(
          'Prompt unUpvote failed: ${response.statusCode} ${response.body} ${response.reasonPhrase}');
    }
  }
}
