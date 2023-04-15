import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'model_utils.dart';
import 'prompt.dart';

part 'chat_snippet.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class ChatSnippet with EquatableMixin {
  final String id;
  final String snippet;
  final Prompt prompt;

  @JsonKey(fromJson: jsonToDate, toJson: dateToJson)
  final DateTime updatedOn;

  ChatSnippet({
    required this.id,
    required this.snippet,
    required this.prompt,
    required this.updatedOn,
  });

  factory ChatSnippet.fromJson(Map json) => _$ChatSnippetFromJson(json);

  Map toJson() => _$ChatSnippetToJson(this);

  @override
  List<Object?> get props => [
        snippet,
        id,
        prompt,
        updatedOn,
      ];
}
