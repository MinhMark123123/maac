# MAAC: Robust MVVM with Lifecycle Management 🚀

[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

**MAAC** is a framework that brings professional architectural patterns to Flutter, inspired by the robustness of Android development. It provides a clean separation of concerns, automatic lifecycle synchronization, and reduced boilerplate through code generation.

---

## 📚 Documentation & Specifications

We have moved all detailed specifications and guides to our centralized documentation hub. Please visit the links below for the most up-to-date information:

👉 [**Main Documentation Hub**](./docs/README.md)

### Detailed API Specifications:
- 🛠️ [**`maac_mvvm` (Core)**](./docs/spec_core.md)
- ✨ [**Annotations & Generator**](./docs/spec_annotations.md)
- 💉 [**DI Integration (GetIt)**](./docs/spec_di_get_it.md)
- 🌊 [**Riverpod Integration**](./docs/spec_riverpod.md)

---

## 📦 Packages in the Ecosystem

| Package | Status | Description |
| :--- | :--- | :--- |
| **`maac_mvvm`** | [![pub package](https://img.shields.io/pub/v/maac_mvvm.svg)](https://pub.dev/packages/maac_mvvm) | Core MVVM & Lifecycle Logic |
| **`maac_mvvm_annotation`** | [![pub package](https://img.shields.io/pub/v/maac_mvvm_annotation.svg)](https://pub.dev/packages/maac_mvvm_annotation) | Declarative Binding Annotations |
| **`maac_mvvm_generator`** | [![pub package](https://img.shields.io/pub/v/maac_mvvm_generator.svg)](https://pub.dev/packages/maac_mvvm_generator) | Boilerplate Code Generator |
| **`maac_mvvm_with_get_it`** | [![pub package](https://img.shields.io/pub/v/maac_mvvm_with_get_it.svg)](https://pub.dev/packages/maac_mvvm_with_get_it) | DI Support (GetIt) |
| **`maac_mvvm_with_riverpod`** | [![pub package](https://img.shields.io/pub/v/maac_mvvm_with_riverpod.svg)](https://pub.dev/packages/maac_mvvm_with_riverpod) | Riverpod Support |

---

## 🚦 Quick Start

Choose the level that fits your project needs:

### 1. Basic (Core Essentials)
Ideal for small projects or getting started with MVVM & Lifecycle.
```bash
flutter pub add maac_mvvm
```

### 2. DI Integration (GetIt)
Add this if you want seamless dependency injection with GetIt.
```bash
flutter pub add maac_mvvm_with_get_it
```

### 3. Full Power (Automation)
Enable code generation to eliminate all reactive boilerplate.
```bash
# Dependencies
flutter pub add maac_mvvm_annotation
# Dev Dependencies
flutter pub add --dev maac_mvvm_generator build_runner
```

---

## 🗺️ Learning Path

We recommend following our tiered tutorials to master the MAAC ecosystem:

- 🟢 [**Level 1: Core Essentials**](./docs/01_tutorial_basic_mvvm.md) - Master basic MVVM, StreamData, and lifecycle hooks.
- 🟡 [**Level 2: Dependency Injection**](./docs/02_tutorial_di_integration.md) - Decouple your code using GetIt integration.
- 🔴 [**Level 3: Full Power**](./docs/03_tutorial_full_power.md) - Eliminate boilerplate with annotations and code generation.

---

## 🤝 Contributing

We welcome contributions from the community! Feel free to open issues or submit pull requests.

```bash
# Setup for development
melos bootstrap
melos run lint:all
```

**Maintainer**: [MinhMark123123](https://github.com/MinhMark123123)