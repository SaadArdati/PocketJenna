// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map json) => Chat(
      id: json['id'] as String,
      prompt: Prompt.fromJson(Map<String, dynamic>.from(json['prompt'] as Map)),
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => ChatMessage.fromJson(e as Map))
          .toList(),
      createdOn: jsonToDate(json['createdOn'] as int?),
      updatedOn: jsonToDate(json['updatedOn'] as int?),
    );

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'id': instance.id,
      'prompt': instance.prompt.toJson(),
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'createdOn': dateToJson(instance.createdOn),
      'updatedOn': dateToJson(instance.updatedOn),
    };
