// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../models/chat.dart';

part 'user_model.g.dart';

DateTime? fromJsonTimestamp(dynamic json) {
  if (json is int) {
    return DateTime.fromMillisecondsSinceEpoch(json);
  } else {
    return null;
  }
}

int? toJsonTimestamp(DateTime? date) {
  return date?.millisecondsSinceEpoch;
}

@JsonSerializable(explicitToJson: true, anyMap: true)
class UserModel extends Equatable {
  late String id;
  final int tokens;
  final Map<String, String> chatSnippets;

  @JsonKey(fromJson: fromJsonTimestamp, toJson: toJsonTimestamp)
  final DateTime? lastUpdate;

  UserModel({
    String? id,
    this.tokens = 0,
    Map<String, String>? chatSnippets,
    this.lastUpdate,
  }) : chatSnippets = chatSnippets ?? {} {
    if (id != null) {
      this.id = id;
    }
  }

  UserModel copyWith({
    int? tokens,
    Map<String, String>? chatSnippets,
  }) {
    return UserModel(
      tokens: tokens ?? this.tokens,
      chatSnippets: chatSnippets ?? this.chatSnippets,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [id, tokens, chatSnippets, lastUpdate];
}
