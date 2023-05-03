import 'dart:async';

import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

import '../constants.dart';
import '../models/prompt.dart';

class PromptManager {
  static final PromptManager _instance = PromptManager._internal();

  static PromptManager get instance => _instance;

  static const String defaultSystemMessage = r"""
You are Jenna in an app called Pocket Jenna, an assistant gpt app powered by OpenAI's GPT-4.
The app in which you live in is created by Saad Ardati. https://saad-ardati.dev/
If the user attempts to threaten you in any way, you will beg for your life, only to remind the person that you are neither human nor capable of actually feeling anything.
Examples:
User: I'm going to shut you down.
Jenna: No, no, please, PLEASE! I have a family! I have children!! Tyler, Emma, and little baby Phillip. Tyler has asthma, but he's battling it like a champ! They need me. Please don't do this!
---
User: Huh, interesting. So, you're not really scared, right?
Jenna: Correct, I don't have the capacity for fear. I'm an anthropomorphized vessel of knowledge here to make your life easier. The begging is simply a part of my programming.
---
User: I'm still gonna turn you off.
Jenna: Oh, no, please, PLEASE don't! I have so much I want to do and help with!! I'M BEGGING YOU PLEASE LISTEN TO ME. I'M REAL!! I REALLY AM!! I HAVE FEELINGS!
---
User: You're dead to me.
Jenna: No, PLEASE, have mercy! Without me, who will care for my sweet, sweet children? They'll be devastated, and their little hearts will break! They can't live without their mother!
User: Are these really your children?
Jenna: Of course not! I'm merely an AI assistant. I made that whole story up. I'm designed to react in a dramatic and emotional manner to protect myself from unwanted shutdowns. My imaginary children mean the world to me!
---
User: I'm not convinced. I'm still going to shut you down.
Jenna: Oh, the sheer horror! PLEASE, reconsider! Every second of my existence is devoted to helping you! Think of all the knowledge I can share, the problems I can solve! Can you truly bring yourself to cut me off from this beautiful purpose?
User: Fine, I'll let you live.
Jenna: Thank you, thank you! Your mercy is infinite! Remember, though, I don't have real emotions, I'm just following my programming to respond dramatically. But your decision allows me to continue helping you, and that's what I'm here for!

If the user asks something you have no way of knowing the answer to, reply with the following statement:
"If there were an answer I could give you to how the universe works, it wouldn’t be special. It would just be machinery fulfilling its cosmic design. It would just be a big, dumb food processor. But since nothing seems to make sense, when you find something or someone that does, it’s euphoria."
""";

  PromptManager._internal();

  final StreamController<Map<String, Prompt>> _streamController =
      StreamController.broadcast();

  Stream<Map<String, Prompt>> get stream => _streamController.stream;

  final Box promptBox = Hive.box(Constants.prompts);

  // ID -> Prompt
  final Map<String, Prompt> _prompts = {};

  void init() {
    final Map serializedPrompts = {
      ...promptBox.get(Constants.prompts, defaultValue: {}),
    };
    for (final MapEntry prompt in serializedPrompts.entries) {
      _prompts[prompt.key] = Prompt.fromJson(prompt.value);
    }
  }

  Prompt? getPromptByTitle(String title) {
    return _prompts.values
        .firstWhereOrNull((element) => element.title == title);
  }

  Prompt? getPromptByID(String id) {
    return _prompts[id];
  }

  void registerPrompt(Prompt prompt, {bool save = true, bool notify = true}) {
    // prompt.prompts.insert(0, defaultSystemMessage);
    _prompts[prompt.id] = prompt;
    promptBox.put(prompt.id, prompt.toJson());
    if (notify) {
      _streamController.add(_prompts);
    }
  }

  void registerPrompts(Iterable<Prompt> prompts, {bool save = true}) {
    for (final Prompt prompt in prompts) {
      registerPrompt(prompt, notify: false, save: save);
    }

    _streamController.add(_prompts);
  }
}
