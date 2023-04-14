import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'chat.dart';

part 'auth_model.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class AuthModel extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const AuthModel({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  AuthModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? authKey,
    List<Chat>? chats,
  }) =>
      AuthModel(
        id: id ?? this.id,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
      );

  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthModelToJson(this);

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];
}
