# maac_mvvm_generator

[![pub package](https://img.shields.io/pub/v/maac_mvvm_generator.svg)](https://pub.dev/packages/maac_mvvm_generator)

A powerful code generator that automates the creation of state getters for MAAC ViewModels, drastically reducing boilerplate code.

---

## 🚀 Key Features

- **Boilerplate Elimination**: Automatically generates read-only `StreamData` getters from mutable private fields.
- **BuildRunner Integration**: Seamlessly works with the standard Flutter build pipeline.

---

## 📖 Usage

### 1. Add dependencies to your `pubspec.yaml`

```yaml
dev_dependencies:
  maac_mvvm_generator: any
  build_runner: any
```

### 2. Run the generator

```bash
dart run build_runner build
```

### 3. Generated Code Benefit

The generator will turn your private `_field` with `@Bind()` into a public `field` stream getter in a `.g.dart` file.

---

## 🧭 Documentation

For detailed API specifications, installation guides, and tutorials, please visit our centralized documentation hub:

👉 [**MAAC Documentation Hub**](https://github.com/MinhMark123123/maac/blob/main/docs/README.md)

### Specific Guides:
- ⚙️ [**Generator Specification**](https://github.com/MinhMark123123/maac/blob/main/docs/spec_annotations.md#generator-maac_mvvm_generator)
- 🚀 [**Quick Start Guide**](https://github.com/MinhMark123123/maac/blob/main/docs/README.md#quick-start)

---

## 🤝 Contributing

Contributions are welcome! Please visit the [main repository](https://github.com/MinhMark123123/maac) for more information.
