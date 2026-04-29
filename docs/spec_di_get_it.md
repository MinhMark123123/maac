# 💉 API Specification: `maac_mvvm_with_get_it`

This package provides a bridge between MAAC and the [GetIt](https://pub.dev/packages/get_it) service locator, enabling clean dependency injection for your ViewModels.

---

## 📦 Installation

To add the DI integration package to your project, run:

```bash
flutter pub add maac_mvvm_with_get_it
```

---

## 🏗️ DependencyViewModelWidget

A specialized version of `ViewModelWidget` that automatically resolves its ViewModel from GetIt.

### Usage
Instead of manually initializing your ViewModel in `createViewModel`, `DependencyViewModelWidget` handles it for you.

```dart
class MyPage extends DependencyViewModelWidget<MyViewModel> {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, MyViewModel viewModel) {
    return ...;
  }
}
```

### Key Features
- **Automatic Resolution**: Uses `GetIt` to find the registered factory for the ViewModel type `<MyViewModel>`.
- **Scope Management**: 
    - **Creation**: When the widget is initialized, it opens a new GetIt scope (if configured) or simply resolves a fresh instance.
    - **Cleanup**: When the widget is disposed, it automatically unregisters the ViewModel instance from its internal cache to prevent memory leaks. This ensures that every time you enter a page, you get a **fresh** ViewModel instance.

---

## 🛠️ Registration & Injection

### `registerViewModel<T extends ViewModel>(FactoryFunc factory)`
Registers a ViewModel factory. Unlike standard GetIt registration, this uses a specialized internal container to manage ViewModel lifecycles correctly.

```dart
void setup() {
  // Use 'inject()' or 'GetIt.I.get()' to resolve repositories
  registerViewModel(() => HomeViewModel(repository: inject()));
}
```

### `injectViewModel`
A global reference to the internal GetIt instance used specifically for ViewModels. You can use it to manually resolve ViewModels if needed, though `DependencyViewModelWidget` is the recommended way to keep your UI code clean.

---

## 🚦 Integration Workflow

1. **Register**: Define your ViewModels in a setup file (e.g., `injection.dart`) using `registerViewModel`.
2. **Setup**: Call your setup function in `main.dart` before `runApp`.
3. **Inherit**: Use `DependencyViewModelWidget` for your pages.
4. **Enjoy**: The ViewModel is injected automatically with all its dependencies resolved from your main GetIt instance.

