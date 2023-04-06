import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'chat_message.dart';
import 'model_utils.dart';
import 'prompt.dart';

part 'chat.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class Chat with EquatableMixin {
  final String id;
  final Prompt prompt;
  final List<ChatMessage> messages;

  @JsonKey(fromJson: jsonToDate, toJson: dateToJson)
  final DateTime createdOn;

  @JsonKey(fromJson: jsonToDate, toJson: dateToJson)
  final DateTime updatedOn;

  List<ChatMessage> toFullChat() => [...prompt.toChatMessages, ...messages];

  Chat({
    required this.id,
    required this.prompt,
    List<ChatMessage>? messages,
    DateTime? createdOn,
    DateTime? updatedOn,
  })  : updatedOn = updatedOn ?? DateTime.now(),
        createdOn = createdOn ?? DateTime.now(),
        messages = messages ?? [];

  Chat.simple({
    required this.prompt,
    List<ChatMessage>? messages,
    DateTime? createdOn,
    DateTime? updatedOn,
  })  : id = const Uuid().v4(),
        updatedOn = updatedOn ?? DateTime.now(),
        createdOn = createdOn ?? DateTime.now(),
        messages = messages ?? [];

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);

  @override
  List<Object?> get props => [messages];
}
