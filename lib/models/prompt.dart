import 'package:dart_openai/openai.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'chat_message.dart';
import 'model_utils.dart';

part 'prompt.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class Prompt with EquatableMixin {
  final String id;
  final String userID;
  final List<String> prompts;
  final String title;
  final String icon;

  @JsonKey(fromJson: jsonToDate, toJson: dateToJson)
  final DateTime createdOn;
  @JsonKey(fromJson: jsonToDate, toJson: dateToJson)
  final DateTime updatedOn;

  Prompt({
    required this.id,
    required this.userID,
    required this.prompts,
    required this.title,
    required this.icon,
    required this.createdOn,
    required this.updatedOn,
  });

  Prompt.simple({
    required this.title,
    required this.prompts,
    required this.icon,
    required this.userID,
  })  : id = const Uuid().v4(),
        createdOn = DateTime.now(),
        updatedOn = DateTime.now();

  List<ChatMessage> get toChatMessages => [
        ...prompts.map((prompt) => ChatMessage.simple(
            text: prompt, role: OpenAIChatMessageRole.system))
      ];

  factory Prompt.fromJson(Map json) => _$PromptFromJson(json);

  Map toJson() => _$PromptToJson(this);

  @override
  List<Object?> get props => [id, prompts, title, icon];
}
