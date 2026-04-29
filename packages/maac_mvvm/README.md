# maac_mvvm

[![pub package](https://img.shields.io/pub/v/maac_mvvm.svg)](https://pub.dev/packages/maac_mvvm)

The core package of the MAAC ecosystem. It provides the base classes for the MVVM pattern and a lifecycle management system that mirrors the robustness of Android development.

---

## 🚀 Key Features

- **Lifecycle Synchronization**: Android-inspired `onResume`, `onPause`, and `onDispose` hooks.
- **Reactive State**: `StreamData` for clean data binding.
- **Efficient Rebuilds**: `StreamDataConsumer` for granular UI updates.

---

## 📖 Usage

### 1. Define your ViewModel

```dart
class CounterViewModel extends ViewModel {
  late final _counter = 0.mutableData(this);
  late final counter = _counter.streamData;

  void increment() => _counter.postValue(counter.data + 1);
}
```

### 2. Build your UI

```dart
class CounterPage extends ViewModelWidget<CounterViewModel> {
  @override
  CounterViewModel createViewModel() => CounterViewModel();

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) {
    return Scaffold(
      body: Center(
        child: StreamDataConsumer<int>(
          streamData: viewModel.counter,
          builder: (context, data) => Text('$data'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## 🧭 Documentation

For detailed API specifications, installation guides, and tutorials, please visit our centralized documentation hub:

👉 [**MAAC Documentation Hub**](https://github.com/MinhMark123123/maac/blob/main/docs/README.md)

### Specific Guides:
- 🛠️ [**Core API Specification**](https://github.com/MinhMark123123/maac/blob/main/docs/spec_core.md)
- 🏗️ [**Architecture Philosophy**](https://github.com/MinhMark123123/maac/blob/main/docs/README.md#architecture-philosophy)
- 🚦 [**Quick Start Guide**](https://github.com/MinhMark123123/maac/blob/main/docs/README.md#quick-start)

---

## 🤝 Contributing

Contributions are welcome! Please visit the [main repository](https://github.com/MinhMark123123/maac) for more information.