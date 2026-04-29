import 'package:maac_example/data/news_repository.dart';
import 'package:maac_example/models/news_article.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';

part 'full_power_news_detail_view_model.g.dart';

@BindableViewModel()
class FullPowerNewsDetailViewModel extends ViewModel {
  final NewsRepository _newsRepository;

  FullPowerNewsDetailViewModel(this._newsRepository);

  int? articleId;

  @Bind()
  late final _article = StreamDataViewModel<NewsArticle?>(defaultValue: null, viewModel: this);

  @Bind()
  late final _isLoading = true.mtd(this);

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
