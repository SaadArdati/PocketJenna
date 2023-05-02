import '../models/chat.dart';

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
}
