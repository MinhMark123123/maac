import 'package:maac_example/data/news_repository.dart';
import 'package:maac_example/models/news_article.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';

part 'full_power_news_view_model.g.dart';

@BindableViewModel()
class FullPowerNewsViewModel extends ViewModel {
  final NewsRepository _newsRepository;

  FullPowerNewsViewModel(this._newsRepository);

  @Bind()
  late final StreamDataViewModel<List<NewsArticle>> _newsState = <NewsArticle>[].mtd(this);

  @Bind()
  late final StreamDataViewModel<bool> _isLoading = true.mtd(this);

  @override
  void onInitState() {
    super.onInitState();
    loadNews();
  }

  Future<void> loadNews() async {
    _isLoading.postValue(true);
    try {
      final news = await _newsRepository.getTopHeadlines();
      _newsState.postValue(news);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading.postValue(false);
    }
  }
}
