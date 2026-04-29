# maac_mvvm_with_riverpod

[![pub package](https://img.shields.io/pub/v/maac_mvvm_with_riverpod.svg)](https://pub.dev/packages/maac_mvvm_with_riverpod)

An extension package that integrates MAAC's lifecycle management with the Riverpod state management library.

---

## 🚀 Key Features

- **ConsumerViewModelWidget**: A widget that combines `ViewModelWidget` with Riverpod's `WidgetRef`.
- **RiverViewModel**: A base ViewModel class that is designed to hold and manage Riverpod state.

---

## 📖 Usage

### 1. Define your ViewModel with Riverpod state

```dart
class MyViewModel extends RiverViewModel<MyState> {
  MyViewModel({required super.uiState});
}
```

### 2. Use `ConsumerViewModelWidget`

```dart
class MyPage extends ConsumerViewModelWidget<MyViewModel> {
  @override
  ProviderListenable<MyViewModel> viewModelProvider() => myViewModelProvider;

  @override
  Widget buildWidget(BuildContext context, WidgetRef ref, MyViewModel viewModel) {
    return Text('ViewModel integrated with Riverpod');
  }
}
```

---

## 🧭 Documentation

For detailed API specifications, installation guides, and tutorials, please visit our centralized documentation hub:

👉 [**MAAC Documentation Hub**](https://github.com/MinhMark123123/maac/blob/main/docs/README.md)

### Specific Guides:
- 🌊 [**Riverpod Integration Specification**](https://github.com/MinhMark123123/maac/blob/main/docs/spec_riverpod.md)
- 🚀 [**Quick Start Guide**](https://github.com/MinhMark123123/maac/blob/main/docs/README.md#quick-start)

---

## 🤝 Contributing

Contributions are welcome! Please visit the [main repository](https://github.com/MinhMark123123/maac) for more information.