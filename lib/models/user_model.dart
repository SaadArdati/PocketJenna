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

  @JsonKey(fromJson: jsonToDate, toJson: dateToJson)
  final DateTime updatedOn;

  UserModel({
    required this.id,
    required this.tokens,
    required this.updatedOn,
    Map<String, ChatSnippet>? chatSnippets,
  }) : chatSnippets = chatSnippets ?? {};

  UserModel copyWith({
    int? tokens,
    Map<String, ChatSnippet>? chatSnippets,
    DateTime? updatedOn,
  }) {
    return UserModel(
      id: id,
      tokens: tokens ?? this.tokens,
      chatSnippets: chatSnippets ?? this.chatSnippets,
      updatedOn: updatedOn ?? this.updatedOn,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [id, tokens, chatSnippets, updatedOn];
}
