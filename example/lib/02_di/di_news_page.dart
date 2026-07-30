import 'package:flutter/material.dart';
import 'package:maac_example/02_di/di_news_view_model.dart';
import 'package:maac_example/models/news_article.dart';
import 'package:maac_example/navigation/routers.dart';
import 'package:maac_example/ui/shared/news_card.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class DiNewsPage extends DependencyViewModelWidget<DiNewsViewModel> {
  const DiNewsPage({super.key});

  @override
  Widget build(BuildContext context, DiNewsViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: const Text('Space News (DI)'), centerTitle: false, backgroundColor: Colors.transparent, elevation: 0),
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
            itemBuilder: (context, index) => NewsCard(article: news[index], detailRoute: AppRoutes.diDetail),
          );
        },
      ),
    );
  }
}
