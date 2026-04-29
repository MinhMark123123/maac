import 'package:maac_example/data/news_repository.dart';
import 'package:maac_example/models/news_article.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

class DiNewsDetailViewModel extends ViewModel {
  final NewsRepository _newsRepository;

  DiNewsDetailViewModel(this._newsRepository);

  int? articleId;

  late final _article = StreamDataViewModel<NewsArticle?>(defaultValue: null, viewModel: this);
  late final _isLoading = true.mtd(this);

  StreamData<NewsArticle?> get article => _article;
  StreamData<bool> get isLoading => _isLoading;

  @override
  void onInitState() {
    super.onInitState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    final id = articleId;
    if (id == null) return;

    _isLoading.postValue(true);
    try {
      final result = await _newsRepository.getArticleById(id);
      _article.postValue(result);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading.postValue(false);
    }
  }
}
