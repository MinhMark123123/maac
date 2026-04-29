import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:maac_example/02_di/di_news_detail_view_model.dart';
import 'package:maac_example/02_di/di_news_view_model.dart';
import 'package:maac_example/03_full/full_power_news_detail_view_model.dart';
import 'package:maac_example/03_full/full_power_news_view_model.dart';
import 'package:maac_example/data/api/news_api.dart';
import 'package:maac_example/data/news_repository.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Network
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<NewsApi>(() => NewsApi(getIt<Dio>()));

  // Repositories
  getIt.registerLazySingleton<NewsRepository>(() => NewsRepositoryImpl(getIt<NewsApi>()));

  // List ViewModels
  registerViewModel<DiNewsViewModel>(() => DiNewsViewModel(getIt<NewsRepository>()));
  registerViewModel<FullPowerNewsViewModel>(() => FullPowerNewsViewModel(getIt<NewsRepository>()));

  // Detail ViewModels
  registerViewModel<DiNewsDetailViewModel>(() => DiNewsDetailViewModel(getIt<NewsRepository>()));
  registerViewModel<FullPowerNewsDetailViewModel>(() => FullPowerNewsDetailViewModel(getIt<NewsRepository>()));
}
