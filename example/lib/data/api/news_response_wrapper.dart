import 'package:json_annotation/json_annotation.dart';
import 'package:maac_example/models/news_article.dart';

part 'news_response_wrapper.g.dart';

@JsonSerializable()
class NewsResponseWrapper {
  final int count;
  final String? next;
  final String? previous;
  final List<NewsArticle> results;

  NewsResponseWrapper({required this.count, this.next, this.previous, required this.results});

  factory NewsResponseWrapper.fromJson(Map<String, dynamic> json) => _$NewsResponseWrapperFromJson(json);

  Map<String, dynamic> toJson() => _$NewsResponseWrapperToJson(this);
}
