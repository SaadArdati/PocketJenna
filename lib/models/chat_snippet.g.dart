// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_snippet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSnippet _$ChatSnippetFromJson(Map json) => ChatSnippet(
      id: json['id'] as String,
      snippet: json['snippet'] as String,
      prompt: Prompt.fromJson(json['prompt'] as Map),
    );

Map<String, dynamic> _$ChatSnippetToJson(ChatSnippet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'snippet': instance.snippet,
      'prompt': instance.prompt.toJson(),
    };
