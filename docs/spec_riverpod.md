# 🌊 API Specification: `maac_mvvm_with_riverpod`

This package integrates MAAC's lifecycle management with the [Riverpod](https://riverpod.dev/) state management library.

---

## 📦 Installation

To add Riverpod integration to your project, we recommend using the latest compatible versions:

```bash
flutter pub add maac_mvvm_with_riverpod
flutter pub add hooks_riverpod
flutter pub add flutter_hooks
```

---

## 🏗️ ConsumerViewModelWidget

A version of `ViewModelWidget` that provides a `WidgetRef`, allowing you to watch and read Riverpod providers directly within the build method.

### How the Bridge Works
`ConsumerViewModelWidget` acts as a specialized `ConsumerWidget`. It:
1.  **Resolves the ViewModel**: It calls `viewModelProvider()` and uses `ref.read` to obtain the instance.
2.  **Synchronizes Lifecycle**: It ensures that MAAC's lifecycle hooks (`onInitState`, `onResume`, etc.) are triggered correctly even when the ViewModel is managed by Riverpod.
3.  **Exposes WidgetRef**: Unlike standard `ViewModelWidget`, the `buildWidget` and `awake` methods give you direct access to `WidgetRef`, enabling granular rebuilds.

### Overrides
- **`viewModelProvider()`**: **Required**. Return the Riverpod provider that provides your `RiverViewModel`.
- **`buildWidget(BuildContext context, WidgetRef ref, VM viewModel)`**: **Required**. Build your UI using both the ViewModel and Riverpod's `WidgetRef`.
- **`awake(WidgetRef ref, VM viewModel)`**: Called after initialization, giving you access to `ref` before `onInitState`.

---

## 🧠 RiverViewModel<UIState>

A `ViewModel` that is natively aware of a Riverpod `StateController`.

### Key Features
- **Typed UI State**: Automatically holds a reference to a `StateController<UIState>`.
- **Reactive Updates**: Use the `uiState` controller to trigger rebuilds across your app.

### Methods & Properties
- **`uiState`**: Access the `StateController` to update the state.
- **`onInitState()` (inherited)**: Perfect for initial state setup.

---

## 🚦 Recommended Implementation Pattern

Combining MAAC and Riverpod allows for a powerful, reactive architecture:

1. **State**: Define a standard Dart class for your UI State.
2. **Provider**: Create a `StateProvider` for the state and a `Provider` for the `RiverViewModel`.
3. **ViewModel**: Inherit from `RiverViewModel` and use the `uiState` to modify data.
4. **Widget**: Inherit from `ConsumerViewModelWidget` and use `ref.watch(viewModel.someSelector)` for granular rebuilds.

```dart
class MyPage extends ConsumerViewModelWidget<MyViewModel> {
  @override
  AutoDisposeProvider<MyViewModel> viewModelProvider() => myViewModelProvider;

  @override
  Widget buildWidget(BuildContext context, WidgetRef ref, MyViewModel viewModel) {
     // Use ref.watch for reactive updates from Riverpod
     final data = ref.watch(viewModel.myDataSelector);
     return Text(data);
  }
}
```

