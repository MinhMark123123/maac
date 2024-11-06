![MVVM](https://github.com/MinhMark123123/maac/blob/main/resources/mvvm.png)

maac_mvvm_with_get_it is an extension package of maac_mvvm that is used with GetIt. This
package retains the architecture and components of the maac_mvvm package, such as ViewModel, StreamData, ViewModelWidget,
and adds additional components that support RiverPod is DependencyViewModelWidget .

It's simple, clean, and very easy to implement.

Please also check the [maac_mvvm](https://pub.dev/packages/maac_mvvm)
## Features

### DependencyViewModelWidget

A place to build UI widgets that the ViewModel is binding to also support dependency ViewModel with GetIt

## Getting Started

- Install from pub: `flutter pub add maac_mvvm_with_get_it`

## Usage
### 1 - Install package
`flutter pub add maac_mvvm_with_get_it`
### 2 - Create your ViewModel
With this package we create a ViewModel that inherits from RiverViewModel to manage the logic and lifecycle of the widget. This
ViewModel will have access to the state and the methods defined in RiverViewModel, as well as the ones defined in maac_mvvm's ViewModel.
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
The DependencyViewModelWidget will only contain two methods: createViewModel and build.

- The buildWidget method is where you build the interface
- The viewModelProvider method is where you provide your ViewModel provider.

Similar with the maac_mvvm, We don't need to worry about the other lifecycles of the widget because they will be called automatically
corresponding to the ViewModel.

```dart
class ExamplePage extends DependencyViewModelWidget<ExamplePageViewModel> {
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
class ExamplePage extends DependencyViewModelWidget<ExamplePageViewModel> {
  final int initValue;
  const ExamplePage({super.key, required this.initValue});

  @override
  ExamplePage createViewModel(BuildContext context) => ExamplePageViewModel();

  @override
  void awake(BuildContext context, ExamplePageViewModel viewModel) => viewModel.setup(initValue);

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
// This is our global ServiceLocator
GetIt sl = GetIt.instance;

void setupGetIt() {
  //setup your GetIt dependencies injection.
}

void main() {
  setupGetIt();
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

class ExamplePage extends DependencyViewModelWidget<ExamplePageViewModel> {
  const ExamplePage({super.key});

  @override
  ExamplePageViewModel createViewModel(BuildContext context) => ExamplePageViewModel();

  @override
  Widget build(BuildContext context, ExamplePageViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: const Text("Main")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
              textAlign: TextAlign.center,
            ),
            StreamDataConsumer(
              builder: (context, data) {
                return Text(
                  '$data',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
              streamData: viewModel.uiState,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: sl.get<ExamplePageViewModel>().incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
class ExamplePageViewModel extends ViewModel {
  late final _uiState = 0.mutableData(this);
  late final uiState = _uiState.streamData;

  void incrementCounter() {
    _uiState.postValue(_uiState.data + 1);
  }

  int returnTestValue() {
    return 1;
  }
}
```

### API:
DependencyViewModelWidget
- `awake`
- `createViewModel`
- `buildWidget`
- `setupMockViewModel`

## Additional Information
Any PR is a great help. Thanks