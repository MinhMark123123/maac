import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maac_example/01_basic/basic_news_view_model.dart';
import 'package:maac_example/data/api/news_api.dart';
import 'package:maac_example/data/news_repository.dart';
import 'package:maac_example/models/news_article.dart';
import 'package:maac_example/navigation/routers.dart';
import 'package:maac_example/ui/shared/news_card.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

class BasicNewsPage extends ViewModelWidget<BasicNewsViewModel> {
  const BasicNewsPage({super.key});

  @override
  BasicNewsViewModel createViewModel() {
    // Manual dependency injection for Level 01
    final api = NewsApi(Dio());
    final repository = NewsRepositoryImpl(api);
    return BasicNewsViewModel(repository);
  }

  @override
  Widget build(BuildContext context, BasicNewsViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: const Text('Space News (Basic)'), centerTitle: false, backgroundColor: Colors.transparent, elevation: 0),
      // StreamDataConsumer2 combines `isLoading` and `newsState` into a
      // single rebuild-on-either-source widget, instead of nesting a
      // StreamDataConsumer<bool> inside a StreamDataConsumer<List<...>>.
      body: StreamDataConsumer2<bool, List<NewsArticle>>(
        streamData1: viewModel.isLoading,
        streamData2: viewModel.newsState,
        builder: (context, isLoading, news) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: news.length,
            itemBuilder: (context, index) => NewsCard(article: news[index], detailRoute: AppRoutes.basicDetail),
          );
        },
      ),
    );
  }
}
