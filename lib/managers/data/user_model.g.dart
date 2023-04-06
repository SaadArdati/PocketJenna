// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map json) => UserModel(
      id: json['id'] as String?,
      tokens: json['tokens'] as int? ?? 0,
      chatSnippets: (json['chatSnippets'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      lastUpdate: fromJsonTimestamp(json['lastUpdate']),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'tokens': instance.tokens,
      'chatSnippets': instance.chatSnippets,
      'lastUpdate': toJsonTimestamp(instance.lastUpdate),
    };
