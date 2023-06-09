// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prompt _$PromptFromJson(Map json) => Prompt(
      id: json['id'] as String,
      userID: json['userID'] as String,
      prompts:
          (json['prompts'] as List<dynamic>).map((e) => e as String).toList(),
      title: json['title'] as String,
      icon: json['icon'] as String,
      createdOn: jsonToDate(json['createdOn'] as int?),
      updatedOn: jsonToDate(json['updatedOn'] as int?),
      isPublic: json['isPublic'] as bool,
      description: json['description'] as String?,
      saves:
          (json['saves'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$PromptToJson(Prompt instance) => <String, dynamic>{
      'id': instance.id,
      'userID': instance.userID,
      'prompts': instance.prompts,
      'title': instance.title,
      'description': instance.description,
      'icon': instance.icon,
      'isPublic': instance.isPublic,
      'createdOn': dateToJson(instance.createdOn),
      'updatedOn': dateToJson(instance.updatedOn),
      'saves': instance.saves,
    };
