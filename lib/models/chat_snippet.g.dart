// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_snippet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSnippet _$ChatSnippetFromJson(Map json) => ChatSnippet(
      id: json['id'] as String,
      snippet: json['snippet'] as String,
      promptTitle: json['promptTitle'] as String,
      promptIcon: json['promptIcon'] as String,
      updatedOn: jsonToDate(json['updatedOn'] as int?),
    );

Map<String, dynamic> _$ChatSnippetToJson(ChatSnippet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'snippet': instance.snippet,
      'promptTitle': instance.promptTitle,
      'promptIcon': instance.promptIcon,
      'updatedOn': dateToJson(instance.updatedOn),
    };
