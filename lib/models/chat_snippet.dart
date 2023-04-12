import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'prompt.dart';

part 'chat_snippet.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class ChatSnippet with EquatableMixin {
  final String id;
  final String snippet;
  final Prompt prompt;

  ChatSnippet({
    required this.id,
    required this.snippet,
    required this.prompt,
  });

  factory ChatSnippet.fromJson(Map json) => _$ChatSnippetFromJson(json);

  Map toJson() => _$ChatSnippetToJson(this);

  @override
  List<Object?> get props => [
        snippet,
        id,
        prompt,
      ];
}
