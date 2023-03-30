.. uml::

@startuml
class View
class ViewModel
class Model

View -> ViewModel : Binds to
ViewModel -> Model : Accesses
Model -> ViewModel : Notifies changes
ViewModel -> View : Updates UI
@enduml

maac_mvvm is a package that supports simple implementation of the MVVM pattern. 
The package doesn't wrap any dependency injection inside with this, you can choose any framework dependency injection you want. It simply has three components: ViewModel, StreamData, and ViewModelWidget. 

It's simple, clean, and very easy to implement.

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
### 1 - Install package 
`flutter pub add maac_mvvm`
### 2 - Create your ViewModel
The below ViewModel is a simple ViewModel that hold logic increase counter from widget
```dart
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
### 3 - Create your Widget bind's with ViewModel
The ViewModelWidget will only contain two methods: createViewModel and build. 

- The build method is where you build the interface  
- The createViewModel method is where you initialize the corresponding ViewModel. 

We don't need to worry about the other lifecycles of the widget because they will be called automatically corresponding to the ViewModel.




```dart
class ExamplePage extends ViewModelWidget<ExamplePageViewModel> {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  ExamplePageViewModel createViewModel(BuildContext context) => ExamplePageViewModel();

  @override
  Widget build(BuildContext context, ExamplePageViewModel viewModel) {
    return BuildYourUiWidget();
  }
}
```
In case the widget has properties passed in and we need to pass them to the ViewModel, we can override awake. 

The awake method will be called immediately after the createViewModel method of ViewModelWidget and before the onInitState method of the ViewModel. This will be helpful for setting up the necessary data.
```dart
class SecondPage extends ViewModelWidget<SecondPageViewModel> {
  final int initValue;
  const SecondPage({super.key, required this.initValue});

  @override
  SecondPageViewModel createViewModel(BuildContext context) => SecondPageViewModel();

  @override
  void awake(BuildContext context, SecondPageViewModel viewModel) => viewModel.setup(initValue);

  @override
  Widget build(BuildContext context, SecondPageViewModel viewModel) {
    return BuildYourUiWidget();;
  }
}
```
### 4 - Listen to data changes from ViewModel
Listen to data changes from ViewModel and update UI with StreamDataConsumer.

A StreamDataConsumer is a widget that listens to changes in a data stream and updates its UI accordingly. It can be used to display data from a ViewModel and update the UI whenever the data changes.

To use a StreamDataConsumer, you first need to create a data stream in your ViewModel. This can be done using a StreamDataViewModel .

Once you have created the data stream, you can pass it to a StreamDataConsumer widget as a parameter. The StreamDataConsumer will then listen to changes in the data stream and update its UI accordingly.

For example, if you have a counter variable in your ViewModel that you want to display in your UI, you can create a StreamDataViewModel for it and pass it to a StreamDataConsumer widget. Whenever the counter changes, the StreamDataConsumer will update its UI to display the new value.
```dart
Widget _buildCounterDisplay(ExamplePageViewModel viewModel) {
  return Center(
    child: StreamDataConsumer<int>(
      streamData: viewModel.uiState,
      builder: (context, data) {
        return Text("You have pressed the button $data times.");
      },
    ),
  );
}
```

### Full Example
```dart
class ExamplePage extends ViewModelWidget<ExamplePageViewModel> {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  ExamplePageViewModel createViewModel(BuildContext context) => ExamplePageViewModel();

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

## Additional Information
Any PR is a great help. Thanks