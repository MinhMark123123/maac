# 📰 maac_mvvm News Reader Example

This example app demonstrates how to use the **maac** ecosystem to build a professional, layered Flutter application following the Android-style MVVM architecture.

---

## ✨ Features

- **Layered Architecture**: Clean separation of Data, Domain, and Presentation layers.
- **Dependency Injection**: Seamless integration with `GetIt` for repository and ViewModel resolution.
- **Reactive UI**: Efficiently updates the UI using `StreamDataConsumer` without `setState`.
- **Code Generation**: Leverages `@BindableViewModel` and `@Bind` to eliminate boilerplate.
- **Simulated Real-World Case**: A full-featured News Reader with list and detail views.

---

## 🏗️ Architecture Layers

### 1. Presentation Layer (`lib/news/presentation/`)
- **ViewModel**: Manages states like `isLoading` and `newsList`.
- **View**: Responsive UI widgets that bind to the ViewModel.

### 2. Domain Layer (`lib/news/domain/`)
- **Entities**: Clean data models (`NewsArticle`).
- **Interfaces**: Repository definitions.

### 3. Data Layer (`lib/data/`)
- **Repository Implementation**: Simulates fetching data from a network or local database.

---

## 🚀 Setup & Running

To get this example running successfully, follow these steps:

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Files
Since this project uses code generation, you MUST run the following command to generate the `.g.dart` files:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Launch the App
```bash
flutter run
```

---

## 📚 Learn More

If you are new to the `maac` ecosystem, we highly recommend following our **[Onboarding Guides](../docs/01_tutorial_basic_mvvm.md)** before diving into this example.
