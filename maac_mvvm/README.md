<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

TODO: maac_mvvm is a package support simple implement the MVVM pattern. The package doesn't wrap any dependency injection inside. It
just has simply 3 component ViewModel, StreamData, and ViewModelWidget simple clean and very easy to implement.

## Features

#### ViewModelWidget:

It is a place to build ui widgets also the viewModel that it's binding .

#### ViewModel:

Which holds the logic and lifecycle of the widget it's binding

#### StreamData:

Wrapper of stream useful to update ui and automatically cancel in dispose of the view model lifecycle

## Getting started

- Install from pub : ```flutter pub add maac_mvvm```
- Install with Github:

## Usage

```dart

class ExamplePage extends ViewModelWidget<ExamplePageViewModel> {
  const ExamplePage({super.key});

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
            return Text("Your are pressed $data ");
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

## Additional information

### API:

#### ViewModelWidget:

-$aWake

-$build

-$createViewModel

#### ViewModel:

-$onInitState

-$onResume

-$onPause

-$onDispose

-$onApplicationResumed

-$onApplicationInactive

-$onApplicationPaused

-$onApplicationDetached

#### StreamData:

-$data

-$asStream

#### StreamDataViewModel:

-$postValue

-$setValue

-$asStream

-$close


