import 'package:json_annotation/json_annotation.dart';

part 'news_article.g.dart';

@JsonSerializable()
class NewsArticle {
  final int id;
  final String title;
  @JsonKey(name: 'summary')
  final String description;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @JsonKey(name: 'published_at')
  final DateTime publishedAt;
  final String url;

  NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.publishedAt,
    required this.url,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) => _$NewsArticleFromJson(json);

  Map<String, dynamic> toJson() => _$NewsArticleToJson(this);
}
