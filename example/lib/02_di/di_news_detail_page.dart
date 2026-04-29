import 'package:flutter/material.dart';
import 'package:maac_example/02_di/di_news_detail_view_model.dart';
import 'package:maac_example/ui/shared/news_detail_content.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class DiNewsDetailPage extends DependencyViewModelWidget<DiNewsDetailViewModel> {
  final int articleId;

  const DiNewsDetailPage({super.key, required this.articleId});

  @override
  void awake(WrapperContext wrapperContext, DiNewsDetailViewModel viewModel) {
    super.awake(wrapperContext, viewModel);
    // Just pass the data, the VM handles the behavior
    viewModel.articleId = articleId;
  }

  @override
  Widget build(BuildContext context, DiNewsDetailViewModel viewModel) {
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
