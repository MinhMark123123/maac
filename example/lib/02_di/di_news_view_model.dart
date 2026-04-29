import 'package:maac_example/data/news_repository.dart';
import 'package:maac_example/models/news_article.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

class DiNewsViewModel extends ViewModel {
  final NewsRepository _newsRepository;

  DiNewsViewModel(this._newsRepository);

  late final StreamDataViewModel<List<NewsArticle>> _newsState = <NewsArticle>[].mtd(this);
  StreamData<List<NewsArticle>> get newsState => _newsState;

  late final StreamDataViewModel<bool> _isLoading = true.mtd(this);
  StreamData<bool> get isLoading => _isLoading;

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
