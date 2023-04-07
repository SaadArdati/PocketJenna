// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prompt _$PromptFromJson(Map json) => Prompt(
      id: json['id'] as String,
      prompts:
          (json['prompts'] as List<dynamic>).map((e) => e as String).toList(),
      title: json['title'] as String,
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$PromptToJson(Prompt instance) => <String, dynamic>{
      'id': instance.id,
      'prompts': instance.prompts,
      'title': instance.title,
      'icon': instance.icon,
    };
