import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maac_example/01_basic/basic_news_view_model.dart';
import 'package:maac_example/data/api/news_api.dart';
import 'package:maac_example/data/news_repository.dart';
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
      body: StreamDataConsumer<bool>(
        streamData: viewModel.isLoading,
        builder: (context, isLoading) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamDataConsumer<List>(
            streamData: viewModel.newsState,
            builder: (context, news) {
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: news.length,
                itemBuilder: (context, index) => NewsCard(article: news[index], detailRoute: AppRoutes.basicDetail),
              );
            },
          );
        },
      ),
    );
  }
}
