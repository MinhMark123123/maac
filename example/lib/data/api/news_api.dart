import 'package:dio/dio.dart';
import 'package:maac_example/data/api/news_response_wrapper.dart';
import 'package:maac_example/models/news_article.dart';
import 'package:retrofit/retrofit.dart';

part 'news_api.g.dart';

@RestApi(baseUrl: "https://api.spaceflightnewsapi.net/v4/")
abstract class NewsApi {
  factory NewsApi(Dio dio, {String baseUrl}) = _NewsApi;

  @GET("articles/")
  Future<NewsResponseWrapper> getArticles({@Query("limit") int limit = 20, @Query("offset") int offset = 0});

  @GET("articles/{id}/")
  Future<NewsArticle> getArticle(@Path("id") int id);
}
