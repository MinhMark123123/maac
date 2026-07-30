# Level 2: Dependency Injection with `maac_mvvm_with_get_it`

As your application grows, you will need to decouple your `ViewModel` from its dependencies (like services and repositories). `maac_mvvm_with_get_it` integrates the popular `get_it` package directly into the `maac` ecosystem.

---

## 🏗️ New Component

1.  **DependencyViewModelWidget**: A specialized version of `ViewModelWidget` that automatically fetches its ViewModel from `GetIt`.

---

## 🚦 Step 1: Register Your ViewModel

Instead of instantiating the `ViewModel` directly in the widget, we register it as a factory using `maac_mvvm_with_get_it`.

```dart
import 'package:example/02_di/di_news_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

void setupDI() {
  final getIt = GetIt.instance;
  
  // Register repositories
  getIt.registerLazySingleton<NewsRepository>(() => NewsRepositoryImpl(NewsApi(Dio())));

  // Use registerViewModel to bind a ViewModel factory to GetIt
  registerViewModel<DiNewsViewModel>(() => DiNewsViewModel(getIt<NewsRepository>()));
}

void main() {
  setupDI();
  runApp(const MyApp());
}
```

---

## 🎨 Step 2: Simplified UI Binding

With `DependencyViewModelWidget`, you no longer need to implement `createViewModel`. The library handles resolution for you.

```dart
import 'package:example/02_di/di_news_view_model.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

// Just extend DependencyViewModelWidget and provide the Type!
class DiNewsPage extends DependencyViewModelWidget<DiNewsViewModel> {
  const DiNewsPage({super.key});

  @override
  Widget build(BuildContext context, DiNewsViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: const Text('Level 2: Space News (DI)')),
      body: StreamDataConsumer2<bool, List<NewsArticle>>(
        streamData1: viewModel.isLoading,
        streamData2: viewModel.newsState,
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

## ⚡ Why Use This?

- **Testability**: Easily swap real repositories with mocks for unit testing.
- **Decoupling**: The View layer doesn't need to know *how* a ViewModel is created or what its dependencies are.
- **Automatic Lifecycle**: Just like Level 1, all lifecycle methods (`onInitState`, `onDispose`) are called automatically.

---

## 🚦 Step 3: Dynamic Detail with DI

When using `DependencyViewModelWidget`, the ViewModel is resolved from GetIt without knowing your specific route parameters. We use the `awake` method — which runs **after** resolution but **before** `onInitState` — to bridge this gap.

```dart
class DiNewsDetailPage extends DependencyViewModelWidget<DiNewsDetailViewModel> {
  final int articleId;
  const DiNewsDetailPage({super.key, required this.articleId});

  @override
  void awake(WrapperContext wrapperContext, DiNewsDetailViewModel viewModel) {
    super.awake(wrapperContext, viewModel);
    // Pass the data to the ViewModel.
    // The ViewModel handles the fetching logic internally in its onInitState.
    viewModel.articleId = articleId;
  }

  @override
  Widget build(BuildContext context, DiNewsDetailViewModel viewModel) {
    return Scaffold(
      body: StreamDataConsumer2<bool, NewsArticle?>(
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

## 🚀 The Final Step

Ready to eliminate all the boilerplate getters? Let's move to **[Level 3: Full Power (Annotations & Generators)](./03_tutorial_full_power.md)**.
