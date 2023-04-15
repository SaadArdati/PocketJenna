// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map json) => UserModel(
      id: json['id'] as String,
      tokens: json['tokens'] as int,
      updatedOn: jsonToDate(json['updatedOn'] as int?),
      chatSnippets: (json['chatSnippets'] as Map?)?.map(
        (k, e) => MapEntry(k as String, ChatSnippet.fromJson(e as Map)),
      ),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'tokens': instance.tokens,
      'chatSnippets':
          instance.chatSnippets.map((k, e) => MapEntry(k, e.toJson())),
      'updatedOn': dateToJson(instance.updatedOn),
    };
