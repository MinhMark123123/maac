import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maac_example/01_basic/basic_news_detail_view_model.dart';
import 'package:maac_example/data/api/news_api.dart';
import 'package:maac_example/data/news_repository.dart';
import 'package:maac_example/ui/shared/news_detail_content.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

class BasicNewsDetailPage extends ViewModelWidget<BasicNewsDetailViewModel> {
  final int articleId;

  const BasicNewsDetailPage({super.key, required this.articleId});

  @override
  BasicNewsDetailViewModel createViewModel() {
    final api = NewsApi(Dio());
    final repository = NewsRepositoryImpl(api);
    // Pass the ID here
    return BasicNewsDetailViewModel(repository, articleId);
  }

  @override
  Widget build(BuildContext context, BasicNewsDetailViewModel viewModel) {
    return Scaffold(
      body: StreamDataConsumer<bool>(
        streamData: viewModel.isLoading,
        builder: (context, isLoading) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamDataConsumer(
            streamData: viewModel.article,
            builder: (context, article) {
              if (article == null) {
                return const Center(child: Text('Article not found'));
              }
              return NewsDetailContent(article: article);
            },
          );
        },
      ),
    );
  }
}
