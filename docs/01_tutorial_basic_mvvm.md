# Level 1: Core Essentials with `maac_mvvm`

Welcome to the **maac** ecosystem! This first level of the guide will teach you the fundamentals of using `maac_mvvm` to build clean, reactive, and lifecycle-aware Flutter applications.

---

## 🏗️ Core Components

`maac_mvvm` introduces three primary building blocks that handle the "V" and "VM" in MVVM:

1.  **ViewModel**: The brain of your screen. It handles business logic, state, and interacts with the data layer.
2.  **StreamData**: A reactive wrapper for your state that notifies the UI when data changes.
3.  **ViewModelWidget**: A specialized widget that manages the lifecycle of your ViewModel automatically.

---

## 🚦 Step 1: Define the ViewModel

The `ViewModel` is where your state lives. We use `StreamDataViewModel` (or the `mtd` extension) to create reactive variables.

```dart
import 'package:example/models/news_article.dart';
import 'package:example/data/news_repository.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

class BasicNewsViewModel extends ViewModel {
  final NewsRepository _newsRepository;
  BasicNewsViewModel(this._newsRepository);

  // Use .mtd(this) to create mutable StreamData bound to this ViewModel's lifecycle
  late final _newsState = <NewsArticle>[].mtd(this);
  late final _isLoading = true.mtd(this);

  // Expose the data as read-only StreamData for the UI
  StreamData<List<NewsArticle>> get newsState => _newsState;
  StreamData<bool> get isLoading => _isLoading;

  @override
  void onInitState() {
    super.onInitState();
    loadNews();
  }

  Future<void> loadNews() async {
    _isLoading.postValue(true);
    final news = await _newsRepository.getTopHeadlines();
    _newsState.postValue(news);
    _isLoading.postValue(false);
  }
}
```

---

## 🎨 Step 2: Create the UI

The `ViewModelWidget` takes care of creating and disposing of the ViewModel for you.

```dart
class BasicNewsPage extends ViewModelWidget<BasicNewsViewModel> {
  const BasicNewsPage({super.key});

  @override
  BasicNewsViewModel createViewModel() {
    // Manual dependency injection for Level 01
    final api = NewsApi(Dio());
    final repository = NewsRepositoryImpl(api);
    return BasicNewsViewModel(repository);
  }

  @override
  Widget build(BuildContext context, BasicNewsViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: const Text('Level 1: Space News')),
      body: StreamDataConsumer<bool>(
        streamData: viewModel.isLoading,
        builder: (context, isLoading) {
          if (isLoading) return const CircularProgressIndicator();
          return StreamDataConsumer<List<NewsArticle>>(
            streamData: viewModel.newsState,
            builder: (context, news) {
              return ListView.builder(
                itemCount: news.length,
                itemBuilder: (context, index) => NewsCard(article: news[index]),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## 🔄 Lifecycle Management

One of the most powerful features of `maac_mvvm` is its automatic lifecycle synchronization. You can override these methods in your `ViewModel`:

- `onInitState()`: Called when the widget is first created (similar to `initState`).
- `onResume()`: Called whenever the widget becomes visible or the app returns from the background.
- `onPause()`: Called when the widget is no longer visible.
- `onDispose()`: Called when the widget is destroyed (cleans up all `StreamData` automatically!).

---

## 🚦 Step 3: Navigating to Detail

To handle dynamic data (like fetching an article by ID) in a basic setup, we pass the parameter through the **constructor**. The ViewModel then uses its own `onInitState` to trigger the fetch.

```dart
class BasicNewsDetailViewModel extends ViewModel {
  final NewsRepository _newsRepository;
  final int articleId; // Receive the ID in the constructor

  BasicNewsDetailViewModel(this._newsRepository, this.articleId);

  @override
  void onInitState() {
    super.onInitState();
    loadArticle(); // Trigger fetch automatically on initialization
  }

  Future<void> loadArticle() async { ... }
}

class BasicNewsDetailPage extends ViewModelWidget<BasicNewsDetailViewModel> {
  final int articleId;
  const BasicNewsDetailPage({super.key, required this.articleId});

  @override
  BasicNewsDetailViewModel createViewModel() {
    // Pass the ID during manual instantiation
    return BasicNewsDetailViewModel(NewsRepositoryImpl(NewsApi(Dio())), articleId);
  }

  @override
  Widget build(BuildContext context, BasicNewsDetailViewModel viewModel) {
    return Scaffold(
      body: StreamDataConsumer<bool>(
        streamData: viewModel.isLoading,
        builder: (context, isLoading) {
          if (isLoading) return const CircularProgressIndicator();
          return StreamDataConsumer(
            streamData: viewModel.article,
            builder: (context, article) => NewsDetailContent(article: article!),
          );
        },
      ),
    );
  }
}
```

---

## ⚡ The Learning Path

You've mastered the basics! Now learn how to eliminate the manual DI boilerplate in **[Level 2: Dependency Injection](./02_tutorial_di_integration.md)**.
