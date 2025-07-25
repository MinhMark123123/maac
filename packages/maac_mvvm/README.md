
![MVVM](https://github.com/MinhMark123123/maac/blob/main/resources/mvvm.png)

maac_mvvm is a package that supports simple implementation of the MVVM pattern. 
The package doesn't wrap any dependency injection inside. With this, you can choose any framework dependency injection you want. It 
simply has three components: ViewModel, StreamData and ViewModelWidget. 

It's simple, clean, and very easy to implement.

## Features

### ViewModelWidget

A place to build UI widgets that the ViewModel is binding to.

### ViewModel

Automatic handling of ViewModel initialization, resumption, pausing, and disposal.

### StreamData

A wrapper of Stream useful to update UI and automatically cancel in the dispose of the ViewModel lifecycle.

## Getting Started

- Install from pub: `flutter pub add maac_mvvm`

## Usage
### 1 - Install package 
`flutter pub add maac_mvvm`
### 2 - Create your ViewModel
The below ViewModel is a simple ViewModel that hold logic increase counter from widget
```dart
class ExamplePageViewModel extends ViewModel {
  ExamplePageViewModel();

  late final _uiState = 0.mutableData(this);
  late final uiState = _uiState.streamData;

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
class ExamplePage extends ViewModelWidget<ExamplePageViewModel> {
  final int initValue;
  const ExamplePage({super.key, required this.initValue});

  @override
  ExamplePage createViewModel(BuildContext context) => ExamplePageViewModel();

  @override
  void awake(WrapperContext wrapperContext, ExamplePageViewModel viewModel) => viewModel.setup(initValue);

  @override
  Widget build(BuildContext context, ExamplePageViewModel viewModel) {
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

  late final _uiState = 0.mutableData(this);
  late final uiState = _uiState.streamData;

  void increaseCounter() {
    _uiState.postValue(_uiState.data + 1);
  }
}
```
#### Simplified Setup with Helper Packages (Optional)
If the code examples above seem a bit verbose for your liking, you can further simplify the setup process by leveraging these three helper packages:
- [maac_mvvm_with_get_it](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_with_get_it)
- [maac_mvvm_annotation](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_annotation)
- [maac_mvvm_generator](https://github.com/MinhMark123123/maac/tree/main/packages/maac_mvvm_generator)
  
Here's how you can set up your application using these packages:
1. Main Application Setup (main.dart)

```dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
// Import for registerViewModel (adjust path if this helper is in your project)
// This might come from maac_mvvm_with_get_it or a similar helper you create.
// For this example, let's assume registerViewModel is available globally after setup.

// This is our global ServiceLocator
GetIt sl = GetIt.instance;
var inject = GetIt.instance;
///fake repository
class SimpleRepository {
  const SimpleRepository();

  Future<String> fakeFetch() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return "Hello there!";
  }
}

///setup your Repository dependency injection
void setupGetIt() {
  sl.registerSingleton(const SimpleRepository());
}

///register your ViewModel
void registerViewModels() {
  registerViewModel(() => ExamplePageViewModel(repository: inject()));
}

void main() {
  setupGetIt();
  registerViewModels();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ExamplePage(),
    );
  }
} 

```
2. Example ViewModel (example_page_view_model.dart)

This ViewModel uses annotations from maac_mvvm_annotation for potential code generation, which simplifies data binding.
```dart
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';

part 'example_view_model.g.dart';

@BindableViewModel()
class ExamplePageViewModel extends ViewModel {
  final SimpleRepository _repository;

  ExamplePageViewModel({required SimpleRepository repository})
      : _repository = repository;
  
  // This will be a StreamData that the UI can listen to.
  // The @Bind annotation (or similar from maac_mvvm_annotation)
  // would set this up for automatic updates or generation.
  @Bind()
  late final _dataApi = "".mutableData(this);

  @override
  void onInitState() {
    super.onInitState();
    Future.delayed(Duration.zero, () {
      _repository.fakeFetch().then((data) => _dataApi.postValue(data));
    });
  }
}

```
3. Example Page (example_page.dart)
 
The ExamplePage uses DependencyViewModelWidget (which might be provided by maac_mvvm_with_get_it or be a custom base class that internally uses GetIt to resolve the ViewModel).
```dart
class ExamplePage extends DependencyViewModelWidget<ExamplePageViewModel> {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context, ExamplePageViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: const Text("B")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamDataConsumer(
              streamData: viewModel.dataApi,
              builder: (context, data) {
                return Text(data);
              },
            ),
          ],
        ),
      ),
    );
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