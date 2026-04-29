# ✨ API Specification: Annotations & Generator

MAAC provides a code generation suite to eliminate the repetitive task of exposing `StreamDataViewModel` as read-only `StreamData`.

---

## 📦 Installation

To use code generation, add these packages to your project:

**Dependencies:**
```bash
flutter pub add maac_mvvm_annotation
```

**Dev Dependencies:**
```bash
flutter pub add --dev maac_mvvm_generator
flutter pub add --dev build_runner
```

---

## 🏷️ Annotations (`maac_mvvm_annotation`)

### `@BindableViewModel()`
Mark any class extending `ViewModel` with this annotation to enable code generation for its fields. This tells the generator to look inside this class for bindable fields.

```dart
@BindableViewModel()
class HomeViewModel extends ViewModel { ... }
```

### `@Bind()`
Applied to fields inside a `@BindableViewModel`. 
- **Target**: Must be a `StreamDataViewModel` (typically created via the `.mtd(this)` extension).
- **Effect**: The generator will create a public getter in the partial file (`.g.dart`) that exposes this field as a read-only `StreamData<T>`.

---

## ⚙️ Generator (`maac_mvvm_generator`)

The generator processes files containing the `@BindableViewModel` annotation and produces a `part` file.

### Setup

1. **Add the part statement** to your ViewModel file:
   ```dart
   import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
   part 'home_view_model.g.dart';
   ```
2. **Annotate your fields** (usually private fields):
   ```dart
   @Bind()
   late final _counter = 0.mtd(this);
   ```
3. **Run the generator**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Generated Code Logic

For every field `_name` annotated with `@Bind()`, the generator produces an extension:
```dart
// Inside home_view_model.g.dart
extension HomeViewModelGetters on HomeViewModel {
  StreamData<int> get counter => _counter;
}
```

### Why this is powerful:
- **Encapsulation**: Your `_counter` remains private and mutable only within the ViewModel.
- **Convenience**: You don't have to manually write `StreamData<int> get counter => _counter;` for every single state variable.
- **Consistency**: The public getter always matches the name of the private variable (minus the underscore).

---

## 💡 Best Practices

- **Naming**: Always name your mutable fields with a leading underscore (e.g., `_uiState`). The generator automatically removes the leading underscore for the public getter.
- **Type Safety**: The generator automatically infers the correct generic type `T` for the `StreamData<T>`.
- **Cleaner UI**: Your Widget code remains clean as it only sees the public `StreamData` properties.

