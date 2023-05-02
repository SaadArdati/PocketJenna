// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map json) => UserModel(
      id: json['id'] as String,
      tokens: json['tokens'] as int,
      updatedOn: jsonToDate(json['updatedOn'] as int?),
      createdOn: jsonToDate(json['createdOn'] as int?),
      chatSnippets: (json['chatSnippets'] as Map?)?.map(
        (k, e) => MapEntry(k as String, ChatSnippet.fromJson(e as Map)),
      ),
      pinnedPrompts: (json['pinnedPrompts'] as List<dynamic>?)
          ?.map((e) => Prompt.fromJson(e as Map))
          .toList(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'tokens': instance.tokens,
      'chatSnippets':
          instance.chatSnippets.map((k, e) => MapEntry(k, e.toJson())),
      'pinnedPrompts': instance.pinnedPrompts.map((e) => e.toJson()).toList(),
      'updatedOn': dateToJson(instance.updatedOn),
      'createdOn': dateToJson(instance.createdOn),
    };
