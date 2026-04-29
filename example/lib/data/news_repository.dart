import 'package:maac_example/data/api/news_api.dart';
import 'package:maac_example/models/news_article.dart';

abstract class NewsRepository {
  Future<List<NewsArticle>> getTopHeadlines();
  Future<NewsArticle> getArticleById(int id);
}

class NewsRepositoryImpl implements NewsRepository {
  final NewsApi _api;

  NewsRepositoryImpl(this._api);

  @override
  Future<List<NewsArticle>> getTopHeadlines() async {
    final response = await _api.getArticles();
    return response.results;
  }

  @override
  Future<NewsArticle> getArticleById(int id) async {
    return await _api.getArticle(id);
  }
}
