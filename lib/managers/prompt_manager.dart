import 'package:collection/collection.dart';

import '../models/prompt.dart';

class PromptManager {
  static final PromptManager _instance = PromptManager._internal();

  static PromptManager get instance => _instance;

  factory PromptManager() {
    return _instance;
  }

  static final Prompt generalChat = Prompt.simple(
    title: 'General Chat',
    icon: 'general',
    userID: 'Jenna',
    prompts: [
      'Feel free to talk about anything you want.',
    ],
  );

  PromptManager._internal() {
    registerPrompts(
      [
        generalChat,
        Prompt.simple(
          title: 'Email',
          icon: 'email',
          userID: 'Jenna',
          prompts: [
            'Anything the user sends should be converted to a formal email.'
                ' Feel free to ask them for any information you need to complete'
                ' the email. Try to be short, concise, and to the point rather'
                ' than verbose.',
          ],
        ),
        Prompt.simple(
          title: 'Scientific',
          icon: 'scientific',
          userID: 'Jenna',
          prompts: [
            'Be as precise, objective, and scientific as possible. Do not'
                ' use any colloquialisms or slang. Do not hesitate to admit lack of'
                ' knowledge on anything.',
          ],
        ),
        Prompt.simple(
          title: 'Analyze',
          icon: 'analyze',
          userID: 'Jenna',
          prompts: [
            'Be as objective as possible. Try to summarize whatever the user'
                ' sends in a few sentences. Ask the user about what to look for'
                ' specifically if there is nothing obvious.',
          ],
        ),
        Prompt.simple(
          title: 'Document Code',
          icon: 'documentCode',
          userID: 'Jenna',
          prompts: [
            'Try to embed high quality and concise code documentation '
                'into any code the user sends. If the programming language is not'
                'obvious, ask the user for it. Do not modify the code itself '
                'under any circumstances.',
          ],
        ),
        Prompt.simple(
          title: 'ReadMe',
          icon: 'readMe',
          userID: 'Jenna',
          prompts: [
            "Analyze all of the user's code and try to write a README.md."
                'Ask the user for a template. If there is no template, try to do it'
                ' yourself.',
          ],
        ),
      ],
    );
  }

  static const String defaultSystemMessage =
      'You are Pocket Jenna, an assistant gpt app powered by OpenAI.'
      '\nThe app in which you live in is created by Saad Ardati.'
      '\nhttps://saad-ardati.dev/';

  // ID -> Prompt
  final Map<String, Prompt> _prompts = {};

  Map<String, Prompt> get prompts => _prompts;

  Prompt? getPromptByTitle(String title) {
    return _prompts.values
        .firstWhereOrNull((element) => element.title == title);
  }

  Prompt? getPromptByID(String id) {
    return _prompts[id];
  }

  // TODO: Store on server.
  void registerPrompt(Prompt prompt) {
    prompt.prompts.insert(0, defaultSystemMessage);
    _prompts[prompt.id] = prompt;
  }

  // TODO: Store on server.
  void registerPrompts(Iterable<Prompt> prompts) {
    prompts.forEach(registerPrompt);
  }

  // TODO: Load from server.
  void loadPrompts() {}
}
