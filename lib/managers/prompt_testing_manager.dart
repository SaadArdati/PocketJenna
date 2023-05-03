import '../models/chat.dart';
import 'data/data_manager.dart';

class PromptTestingManager {
  String? prompt;
  Chat? testChat;

  String? title;
  String? description;

  bool public = false;

  void reset() {
    prompt = null;
    testChat = null;
    title = null;
    description = null;
    public = false;
  }

  bool validate() {
    if (prompt == null) {
      return false;
    }
    if (title == null) {
      return false;
    }
    if (description == null) {
      return false;
    }
    return true;
  }

  Future<void> upload() async {
    assert(validate(), 'Prompt data was not validated!');

    return DataManager.instance.uploadPrompt(
      title: title!,
      prompts: [prompt!],
      icon: 'https://picsum.photos/256',
      description: description,
      public: public,
    );
  }
}
