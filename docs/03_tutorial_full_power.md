# Level 3: Full Power with Annotations & Code Gen

Welcome to the highest level of the **maac** experience! By combining `maac_mvvm_annotation` and `maac_mvvm_generator`, you can eliminate almost all of the repetitive boilerplate when defining reactive states.

---

## 🏗️ New Components

1.  **@BindableViewModel**: Marks a class for code generation.
2.  **@Bind**: Automatically creates a public getter for private `StreamData` members.

---

## 🚦 Step 1: Simplify the ViewModel

Instead of manually writing getters for every `StreamData`, simply annotate your private fields!

```dart
import 'package:example/models/news_article.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';

// Declare the generated file
part 'full_power_news_view_model.g.dart';

@BindableViewModel()
class FullPowerNewsViewModel extends ViewModel {
  final NewsRepository _newsRepository;
  FullPowerNewsViewModel(this._newsRepository);

  @Bind()
  late final _newsState = <NewsArticle>[].mtd(this);

  @Bind()
  late final _isLoading = true.mtd(this);

  // The generator will create 'newsState' and 'isLoading' getters!
  
  @override
  void onInitState() {
     loadNews();
  }
}
```

---

## 🎨 Step 2: Running the Generator

To generate the code, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🏁 Step 3: Use it in your UI

Your code becomes remarkably clean and readable.

```dart
class FullPowerNewsPage extends DependencyViewModelWidget<FullPowerNewsViewModel> {
  const FullPowerNewsPage({super.key});

  @override
  Widget build(BuildContext context, FullPowerNewsViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: const Text('Level 3: Full Power')),
      body: StreamDataConsumer2<bool, List<NewsArticle>>(
        streamData1: viewModel.isLoading, // Using generated getter
        streamData2: viewModel.newsState, // Using generated getter
        builder: (context, isLoading, news) {
          if (isLoading) return const CircularProgressIndicator();
          return NewsList(news: news);
        },
      ),
    );
  }
}
```

---

## ⚡ Why Use Full Power?

- **Speed**: Drastically reduces the time spent writing boilerplate.
- **Error Reduction**: No more misaligned getter types or typo-related bugs.
- **Encapsulation**: Keeps your mutable states private while correctly exposing them as immutable `StreamData` to the UI.

---

## 🚦 Step 4: Full Power Detail

When you combine annotations and dependency injection for a dynamic page, the results are remarkably clean.

```dart
class FullPowerNewsDetailPage extends DependencyViewModelWidget<FullPowerNewsDetailViewModel> {
  final int articleId;
  const FullPowerNewsDetailPage({super.key, required this.articleId});

  @override
  void awake(WrapperContext wrapperContext, FullPowerNewsDetailViewModel viewModel) {
    super.awake(wrapperContext, viewModel);
    // Passing data only, logic is handled internally by VM's onInitState
    viewModel.articleId = articleId;
  }

  @override
  Widget build(BuildContext context, FullPowerNewsDetailViewModel viewModel) {
    return Scaffold(
      body: StreamDataConsumer2<bool, NewsArticle?>(
        // Use the generated getters 'isLoading'/'article'
        streamData1: viewModel.isLoading,
        streamData2: viewModel.article,
        builder: (context, isLoading, article) {
          if (isLoading) return const CircularProgressIndicator();
          return NewsDetailContent(article: article!);
        },
      ),
    );
  }
}
```

---

## 🏁 Conclusion

Congratulations! You have successfully mastered MAAC from basic MVVM to professional, automated architectures. You are now ready to build scalable, reactive, and maintainable Flutter applications.
