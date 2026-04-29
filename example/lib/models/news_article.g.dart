// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsArticle _$NewsArticleFromJson(Map<String, dynamic> json) => NewsArticle(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['summary'] as String,
  imageUrl: json['image_url'] as String,
  publishedAt: DateTime.parse(json['published_at'] as String),
  url: json['url'] as String,
);

Map<String, dynamic> _$NewsArticleToJson(NewsArticle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.description,
      'image_url': instance.imageUrl,
      'published_at': instance.publishedAt.toIso8601String(),
      'url': instance.url,
    };
