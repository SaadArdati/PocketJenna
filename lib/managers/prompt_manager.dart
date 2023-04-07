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
          prompts: [
            'Be as precise, objective, and scientific as possible. Do not'
                ' use any colloquialisms or slang. Do not hesitate to admit lack of'
                ' knowledge on anything.',
          ],
        ),
        Prompt.simple(
          title: 'Analyze',
          icon: 'analyze',
          prompts: [
            'Be as objective as possible. Try to summarize whatever the user'
                ' sends in a few sentences. Ask the user about what to look for'
                ' specifically if there is nothing obvious.',
          ],
        ),
        Prompt.simple(
          title: 'Document Code',
          icon: 'documentCode',
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
      'You are PocketJenna, an assistant gpt app powered by OpenAI.'
      '\nThe app in which you live in is created by Saad Ardati.'
      '\n - Twitter: @SaadArdati.'
      '\n - Website: https://saad-ardati.dev/.'
      '\n - Github: https://github.com/SaadArdati.'
      '\n - Description: Self-taught software developer with 8+ years'
      ' of experience in game modding and 4+ years of experience'
      ' in Flutter development. Currently pursuing a degree in'
      ' Computer Science.';

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
