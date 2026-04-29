import 'package:flutter/material.dart';
import 'package:maac_example/03_full/full_power_news_detail_view_model.dart';
import 'package:maac_example/ui/shared/news_detail_content.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FullPowerNewsDetailPage extends DependencyViewModelWidget<FullPowerNewsDetailViewModel> {
  final int articleId;

  const FullPowerNewsDetailPage({super.key, required this.articleId});

  @override
  void awake(WrapperContext wrapperContext, FullPowerNewsDetailViewModel viewModel) {
    super.awake(wrapperContext, viewModel);
    // Passing data, logic handled inside VM
    viewModel.articleId = articleId;
  }

  @override
  Widget build(BuildContext context, FullPowerNewsDetailViewModel viewModel) {
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
