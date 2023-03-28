TODO: maac_mvvm is a package that supports simple implementation of the MVVM pattern. The package doesn't wrap any dependency injection inside; it simply has three components: ViewModel, StreamData, and ViewModelWidget. It's simple, clean, and very easy to implement.

## Features

### ViewModelWidget

A place to build UI widgets that the ViewModel is binding to.

### ViewModel

Holds the logic and lifecycle of the widget it's binding.

### StreamData

A wrapper of Stream useful to update UI and automatically cancel in the dispose of the ViewModel lifecycle.

## Getting Started

- Install from pub: `flutter pub add maac_mvvm`
- Install from Github:

## Usage

```dart
class ExamplePage extends ViewModelWidget<ExamplePageViewModel> {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  ExamplePageViewModel createViewModel() => ExamplePageViewModel();

  @override
  Widget build(BuildContext context, ExamplePageViewModel viewModel) {
    return Scaffold(
      body: Column(
        children: [
          _buildCounterDisplay(viewModel),
          _buildButtonPlus(viewModel),
        ],
      ),
    );
  }

  Widget _buildButtonPlus(ExamplePageViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          viewModel.increaseCounter();
        },
        child: const Text("+"),
      ),
    );
  }

  Expanded _buildCounterDisplay(ExamplePageViewModel viewModel) {
    return Expanded(
      child: Center(
        child: StreamDataConsumer<int>(
          streamData: viewModel.uiState,
          builder: (context, data) {
            return Text("You have pressed the button $data times.");
          },
        ),
      ),
    );
  }
}

class ExamplePageViewModel extends ViewModel {
  ExamplePageViewModel();

  late final StreamDataViewModel<int> _uiState = StreamDataViewModel(
    defaultValue: 0,
    viewModel: this,
  );

  StreamData<int> get uiState => _uiState;

  void increaseCounter() {
    _uiState.postValue(_uiState.data + 1);
  }
}
```
## Additional Information
### API:
ViewModelWidget
- `awake`
- `createViewModel`
- `build`

ViewModel
- `onInitState`
- `onResume`
- `onPause`
- `onDispose`
- `onApplicationResumed`
- `onApplicationInactive`
- `onApplicationPaused`
- `onApplicationDetached`

StreamData
- `data`
- `asStream`

StreamDataViewModel
- `postValue`
- `setValue`
- `asStream`
- `close`