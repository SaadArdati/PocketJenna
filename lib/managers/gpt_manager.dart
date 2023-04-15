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

class GPTManager extends ChangeNotifier {
  final StreamController<ChatMessage> responseStreamController =
      StreamController<ChatMessage>.broadcast();

  Stream<ChatMessage> get responseStream => responseStreamController.stream;

  StreamSubscription<OpenAIStreamChatCompletionModel>? listener;

  final StreamController<Chat?> chatStreamController =
      StreamController<Chat?>.broadcast();

  Stream<Chat?> get chatStream => chatStreamController.stream;

  Chat? chat;

  List<ChatMessage> get messages => chat!.messages;

  final historyBox = Hive.box(Constants.history);

  Map<String, Chat> history = {};

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
      defaultValue: <String>[],
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
    historyBox.clear();
    final Map serializedHistory = {
      ...historyBox.get(Constants.history, defaultValue: {}),
    };
    history = {
      for (final chat in serializedHistory.entries)
        chat.key: Chat.fromJson(chat.value)
    };
  }

  Future<void> openChat({
    String? chatID,
    Prompt? prompt,
    required bool notify,
  }) async {
    assert(
      (chatID == null) != (prompt == null),
      'Either chatID or prompt must be provided',
    );

    chatStreamController.add(null);

    if (chatID == null) {
      chat = Chat.simple(prompt: prompt!);
      history[chat!.id] = chat!;
    } else {
      chat = history[chatID];

      if (chat != null) {
        DataManager.instance.uploadIfNecessary(chat!);
      } else {
        chat ??= await DataManager.instance.fetchChat(chatID);
      }
      purgeEmptyChats();
    }

    chatStreamController.add(chat);

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
      for (final MapEntry<String, Chat> chat in history.entries)
        chat.key: chat.value.toJson(),
    });

    if (!upload) return;
    print('Uploading chat ${chat!.id}...');
    DataManager.instance.uploadChat(chat!);
  }

  void purgeEmptyChats() {
    history.removeWhere((key, value) => value.messages.isEmpty);
  }

  void deleteChat(String id) {
    history.remove(id);
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
        ...chat!.prompt.toChatMessages
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
