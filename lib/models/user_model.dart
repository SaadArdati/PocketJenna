import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'chat_snippet.dart';
import 'model_utils.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class UserModel extends Equatable {
  final String id;
  final int tokens;
  final Map<String, ChatSnippet> chatSnippets;
  final List<String> pinnedPrompts;

  @JsonKey(fromJson: jsonToDate, toJson: dateToJson)
  final DateTime updatedOn;

  @JsonKey(fromJson: jsonToDate, toJson: dateToJson)
  final DateTime createdOn;

  UserModel({
    required this.id,
    required this.tokens,
    required this.updatedOn,
    required this.createdOn,
    Map<String, ChatSnippet>? chatSnippets,
    List<String>? pinnedPrompts,
  })  : chatSnippets = chatSnippets ?? {},
        pinnedPrompts = pinnedPrompts ?? [];

  UserModel copyWith({
    int? tokens,
    DateTime? updatedOn,
    DateTime? createdOn,
    Map<String, ChatSnippet>? chatSnippets,
    List<String>? pinnedPrompts,
  }) {
    return UserModel(
      id: id,
      tokens: tokens ?? this.tokens,
      updatedOn: updatedOn ?? this.updatedOn,
      createdOn: createdOn ?? this.createdOn,
      chatSnippets: chatSnippets ?? this.chatSnippets,
      pinnedPrompts: pinnedPrompts ?? this.pinnedPrompts,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        tokens,
        chatSnippets,
        updatedOn,
        createdOn,
        pinnedPrompts,
      ];
}
