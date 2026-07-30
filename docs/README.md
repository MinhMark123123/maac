# MAAC Documentation Specifications 🚀

Welcome to the official documentation for **MAAC** (Model-View-ViewModel with Lifecycle). MAAC is a collection of Flutter packages designed to simplify the MVVM architectural pattern while providing Android-inspired lifecycle management and robust code generation.

---

## 📦 Packages

The MAAC ecosystem is composed of several specialized packages:

| Package | Purpose | Specification |
| :--- | :--- | :--- |
| **`maac_mvvm`** | Core MVVM logic & Lifecycle components. | [**Core Spec**](./spec_core.md) |
| **`maac_mvvm_annotation`** | Annotations for code generation. | [**Annotation Spec**](./spec_annotations.md) |
| **`maac_mvvm_generator`** | The build_runner code generator. | [**Generator Spec**](./spec_annotations.md) |
| **`maac_mvvm_with_get_it`** | Dependency Injection integration. | [**GetIt Spec**](./spec_di_get_it.md) |
| **`maac_mvvm_with_riverpod`** | Riverpod state management integration. | [**Riverpod Spec**](./spec_riverpod.md) |
| **`maac_workflow`** | Step-pipeline orchestration (rollback, cancellation, retries, concurrency) for multi-step business logic. | [**Workflow Spec**](./spec_workflow.md) |

---

## 🛠️ Quick Start

### 1. Installation
Choose the tier that fits your project:

**Basic Tier (Core Only)**
```bash
flutter pub add maac_mvvm
```

**DI Tier (GetIt Integration)**
```bash
flutter pub add maac_mvvm_with_get_it
```

**Full Power (Automation Combo)**
```bash
flutter pub add maac_mvvm_annotation
flutter pub add --dev maac_mvvm_generator build_runner
```

### 2. Basic Setup
MAAC relies on `ViewModelWidget` to pair a UI with a `ViewModel`.

```dart
class MyPage extends ViewModelWidget<MyViewModel> {
  @override
  MyViewModel createViewModel() => MyViewModel();

  @override
  Widget build(BuildContext context, MyViewModel viewModel) {
    return Scaffold(...);
  }
}
```

---

## 🗺️ Learning Path

We recommend following our step-by-step tiered tutorials:

- 🟢 [**Level 1: Core Essentials**](./01_tutorial_basic_mvvm.md) - Master `ViewModel`, `StreamData`, and basic lifecycles.
- 🟡 [**Level 2: Dependency Injection**](./02_tutorial_di_integration.md) - Integrate `GetIt` for cleaner architecture.
- 🔴 [**Level 3: Full Power**](./03_tutorial_full_power.md) - Use annotations and generators to eliminate boilerplate.
- 🟣 [**`maac_workflow`**](./spec_workflow.md) - Once your `ViewModel` methods grow multi-step (rollback, cancellation, retries), orchestrate them with a `WorkflowRunner` instead of hand-rolled try/catch.

---

## 🏗️ Architecture Philosophy

MAAC is built on the belief that:
- **UI should be passive**: All logic belongs in the `ViewModel`.
- **Lifecycles matter**: Flutter widgets should have clear `onResume`, `onPause`, and `onDispose` hooks that synchronize automatically with business logic.
- **Boilerplate is the enemy**: Code generation should handle the repetitive parts of data binding.
- **Multi-step logic deserves its own layer**: Once a `ViewModel` method needs rollback, cancellation, or concurrency handling, that's `maac_workflow`'s job, not the `ViewModel`'s.

---

## 🤝 Contributing

We welcome contributions! Please check each package's source for more details on how to contribute or report issues.
