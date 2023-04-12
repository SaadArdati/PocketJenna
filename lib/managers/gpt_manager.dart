import 'dart:async';
import 'dart:developer';

import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../constants.dart';
import '../models/chat.dart';
import '../models/chat_message.dart';
import '../models/message_status.dart';
import '../models/prompt.dart';
import 'data/data_manager.dart';
import 'prompt_manager.dart';

class GPTManager extends ChangeNotifier {
  List<ChatMessage> get messages => currentChat!.messages;

  final StreamController<ChatMessage> responseStreamController =
  StreamController<ChatMessage>.broadcast();
  final historyBox = Hive.box(Constants.history);

  Stream<ChatMessage> get responseStream => responseStreamController.stream;

  StreamSubscription<OpenAIStreamChatCompletionModel>? listener;

  Map<String, Chat> chatHistory = {};

  Chat? currentChat;

  static Future<List<String>> fetchAndStoreModels() async {
    final List<OpenAIModelModel> models = await OpenAI.instance.model.list();

    final List<String> ids = [...models.map((model) => model.id)];
    log(ids.join(', '));

    // If we couldn't find a model that this app supports, return an empty list
    // to indicate an error happened.
    final String? bestModel = findBestModel(ids);
    if (bestModel == null) return [];

    Hive.box(Constants.settings).put(Constants.gptModels, ids);

    return ids;
  }

  static List<String> getModels() {
    return Hive.box(Constants.settings).get(
      Constants.gptModels,
      defaultValue: [],
    );
  }

  static String? findBestModel([List<String>? ids]) {
    final List<String> models = ids ?? getModels();
    if (models.contains('gpt-4')) {
      return 'gpt-4';
    }
    if (models.contains('gpt-3.5-turbo')) {
      return 'gpt-3.5-turbo';
    }

    return null;
  }

  void init() {
    final Map serializedHistory = {
      ...historyBox.get(Constants.history, defaultValue: {}),
    };
    chatHistory = {
      for (final chat in serializedHistory.entries)
        chat.key: Chat.fromJson(chat.value)
    };
  }

  FutureOr<void> openChat({
    String? chatID,
    Prompt? prompt,
    required bool notify,
  }) async {
    assert(
    (chatID == null) != (prompt == null),
    'Either chatID or prompt must be provided',
    );

    if (chatID == null) {
      currentChat = Chat.simple(prompt: prompt!);
      chatHistory[currentChat!.id] = currentChat!;
    } else {
      currentChat = chatHistory[chatID];
      currentChat ??= await DataManager.instance.fetchChat(chatID);
      purgeEmptyChats();
    }
    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopGenerating();
    responseStreamController.close();
    listener?.cancel();
    super.dispose();
  }

  void saveChat({bool upload = true}) {
    historyBox.put(Constants.history, {
      for (final MapEntry<String, Chat> chat in chatHistory.entries)
        chat.key: chat.value.toJson(),
    });

    if (!upload) return;
    DataManager.instance.uploadChat(currentChat!);
  }

  void purgeEmptyChats() {
    chatHistory.removeWhere((key, value) => value.messages.isEmpty);
  }

  void deleteChat(String id) {
    chatHistory.remove(id);
    saveChat();
    notifyListeners();
  }

  bool needsExtendedContext() {
    return false;
    // return currentChat!.type == ChatType.documentCode ||
    //     currentChat!.type == ChatType.scientific ||
    //     currentChat!.type == ChatType.readMe;
  }

  /// Not clean. But it's the most optimized way to do it.
  void sendMessage(String message, {required bool generateResponse}) {
    final ChatMessage userMsg = ChatMessage.simple(
      text: message.trim(),
      role: OpenAIChatMessageRole.user,
      status: MessageStatus.done,
    );
    messages.add(userMsg);
    saveChat();
    notifyListeners();

    if (generateResponse) {
      _generate();
    }
  }

  String findTailoredModel() {
    final List<String> models = getModels();
    if (needsExtendedContext() && models.contains('gpt-4-0314')) {
      return 'gpt-4-0314';
    }

    return findBestModel()!;
  }

  void _generate() {
    final Stream<OpenAIStreamChatCompletionModel> stream =
    OpenAI.instance.chat.createStream(
      model: findTailoredModel(),
      messages: [
        ...currentChat!.prompt.toChatMessages
            .map((chatMessage) => chatMessage.toOpenAI()),
        ...messages.map((msg) => msg.toOpenAI())
      ],
    );

    final ChatMessage responseMsg = ChatMessage.simple(
      text: '',
      role: OpenAIChatMessageRole.assistant,
      status: MessageStatus.waiting,
    );
    messages.add(responseMsg);
    saveChat();
    notifyListeners();
    responseStreamController.add(responseMsg);

    listener = stream.listen(
          (streamChatCompletion) {
        final content = streamChatCompletion.choices.first.delta.content;
        if (content != null) {
          responseMsg.text += content;
          if (responseMsg.status != MessageStatus.streaming) {
            responseMsg.status = MessageStatus.streaming;
            notifyListeners();
          }
        }
        saveChat(upload: false);
        responseStreamController.add(responseMsg);
      },
      onError: (error) {
        responseMsg.text = error.toString();
        responseMsg.status = MessageStatus.errored;
        saveChat();
        responseStreamController.add(responseMsg);
      },
      cancelOnError: false,
      onDone: () {
        if (responseMsg.status == MessageStatus.streaming) {
          responseMsg.status = MessageStatus.done;
        }
        saveChat();
        responseStreamController.add(responseMsg);
        notifyListeners();
      },
    );
  }

  void stopGenerating() {
    if (messages.isEmpty) return;
    listener?.cancel();
    final ChatMessage responseMsg = messages.last;
    if (responseMsg.status == MessageStatus.streaming) {
      responseMsg.status = MessageStatus.done;
      saveChat();
      responseStreamController.add(responseMsg);
      notifyListeners();
    }
  }

  void regenerateLastResponse() {
    if (messages.isEmpty) return;
    final ChatMessage last = messages.last;
    if (last.role != OpenAIChatMessageRole.assistant) return;

    messages.removeLast();
    saveChat();
    notifyListeners();

    _generate();
  }
}
