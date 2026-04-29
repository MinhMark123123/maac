// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_response_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsResponseWrapper _$NewsResponseWrapperFromJson(Map<String, dynamic> json) =>
    NewsResponseWrapper(
      count: (json['count'] as num).toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NewsResponseWrapperToJson(
  NewsResponseWrapper instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results,
};
