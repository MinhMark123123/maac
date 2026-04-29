import 'package:flutter/material.dart';
import 'package:maac_example/03_full/full_power_news_view_model.dart';
import 'package:maac_example/navigation/routers.dart';
import 'package:maac_example/ui/shared/news_card.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FullPowerNewsPage extends DependencyViewModelWidget<FullPowerNewsViewModel> {
  const FullPowerNewsPage({super.key});

  @override
  Widget build(BuildContext context, FullPowerNewsViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: const Text('Space News (Full Power)'), centerTitle: false, backgroundColor: Colors.transparent, elevation: 0),
      body: StreamDataConsumer<bool>(
        // Using generated getter 'isLoading' instead of manual '_isLoading'
        streamData: viewModel.isLoading,
        builder: (context, isLoading) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamDataConsumer<List>(
            // Using generated getter 'newsState'
            streamData: viewModel.newsState,
            builder: (context, news) {
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: news.length,
                itemBuilder: (context, index) => NewsCard(article: news[index], detailRoute: AppRoutes.fullDetail),
              );
            },
          );
        },
      ),
    );
  }
}
