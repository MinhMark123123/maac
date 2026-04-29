# maac_mvvm_with_get_it

[![pub package](https://img.shields.io/pub/v/maac_mvvm_with_get_it.svg)](https://pub.dev/packages/maac_mvvm_with_get_it)

An extension package that integrates MAAC with GetIt, allowing for automatic ViewModel resolution and dependency injection.

---

## 🚀 Key Features

- **DependencyViewModelWidget**: A widget that resolves its own ViewModel from GetIt.
- **Factory Scoping**: Simplified ViewModel registration and lifecycle-aware resolution.

---

## 📖 Usage

### 1. Register your ViewModel

```dart
void setup() {
  registerViewModel(() => MyViewModel());
}
```

### 2. Use `DependencyViewModelWidget`

```dart
class MyPage extends DependencyViewModelWidget<MyViewModel> {
  @override
  Widget build(BuildContext context, MyViewModel viewModel) {
    return Text('ViewModel is automatically resolved from GetIt');
  }
}
```

---

## 🧭 Documentation

For detailed API specifications, installation guides, and tutorials, please visit our centralized documentation hub:

👉 [**MAAC Documentation Hub**](https://github.com/MinhMark123123/maac/blob/main/docs/README.md)

### Specific Guides:
- 💉 [**GetIt Integration Specification**](https://github.com/MinhMark123123/maac/blob/main/docs/spec_di_get_it.md)
- 🚀 [**Quick Start Guide**](https://github.com/MinhMark123123/maac/blob/main/docs/README.md#quick-start)

---

## 🤝 Contributing

Contributions are welcome! Please visit the [main repository](https://github.com/MinhMark123123/maac) for more information.