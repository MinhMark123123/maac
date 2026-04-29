# maac_mvvm_annotation

[![pub package](https://img.shields.io/pub/v/maac_mvvm_annotation.svg)](https://pub.dev/packages/maac_mvvm_annotation)

This package provides the essential annotations (`@BindableViewModel`, `@Bind`) that power the MAAC code generation system.

---

## 🚀 Key Features

- **Declarative Binding**: Mark fields for automatic state exposure.
- **Zero Runtime Overhead**: All logic is handled at build time.

---

## 📖 Usage

```dart
@BindableViewModel()
class MyViewModel extends ViewModel {
  @Bind()
  late final _count = 0.mtd(this); // Generates count stream getter

  void increment() => _count.postValue(_count.data + 1);
}
```

---

## 🧭 Documentation

For detailed API specifications, installation guides, and tutorials, please visit our centralized documentation hub:

👉 [**MAAC Documentation Hub**](https://github.com/MinhMark123123/maac/blob/main/docs/README.md)

### Specific Guides:
- ✨ [**Annotation API Specification**](https://github.com/MinhMark123123/maac/blob/main/docs/spec_annotations.md)
- 🚀 [**Quick Start Guide**](https://github.com/MinhMark123123/maac/blob/main/docs/README.md#quick-start)

---

## 🤝 Contributing

Contributions are welcome! Please visit the [main repository](https://github.com/MinhMark123123/maac) for more information.
