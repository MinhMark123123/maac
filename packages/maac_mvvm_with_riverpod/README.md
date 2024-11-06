![MVVM](https://github.com/MinhMark123123/maac/blob/main/resources/mvvm.png)

maac_mvvm_with_riverpod is an extension package of maac_mvvm that is used with RiverPod. This 
package retains the architecture and components of the maac_mvvm package, such as ViewModel, StreamData, ViewModelWidget,
and adds additional components that support RiverPod, such as ConsumerViewModelWidget and RiverViewModel.

It's simple, clean, and very easy to implement.

Please also check the [maac_mvvm](https://pub.dev/packages/maac_mvvm)
## Features

### ConsumerViewModelWidget

A place to build UI widgets that the ViewModel is binding to.

### RiverViewModel

Holds the logic and lifecycle of the widget it's binding to and it inherits from the ViewModel class of maac_mvvm

## Getting Started

- Install from pub: `flutter pub add maac_mvvm_with_riverpod`

## Usage
### 1 - Install package
`flutter pub add maac_mvvm_with_riverpod`
### 2 - Create your ViewModel
With this package we create a ViewModel that inherits from RiverViewModel to manage the logic and lifecycle of the widget. This 
ViewModel will have access to the state and the methods defined in RiverViewModel, as well as the ones defined in maac_mvvm's ViewModel. 
The below ViewModel is a simple ViewModel that hold logic increase counter from widget
```dart
final _exampleUIStateProvider = StateProvider.autoDispose<ExamplePageUIState>((ref) {
  return ExamplePageUIState();
});

final exampleViewModelProvider = Provider.autoDispose<ExamplePageViewModel>((ref) {
  return ExamplePageViewModel(uiState: ref.watch(_exampleUIStateProvider.notifier));
});

class ExamplePageUIState {
  int counter;

  ExamplePageUIState({this.counter = 0});

  ExamplePageUIState copyWith({int? counter}) {
    return ExamplePageUIState(
      counter: counter ?? this.counter,
    );
  }
}

class ExamplePageViewModel extends RiverViewModel<ExamplePageUIState> {
  ExamplePageViewModel({required super.uiState});
  
}
```
### 3 - Create your Widget bind's with ViewModel
The ConsumerViewModelWidget will only contain two methods: createViewModel and build.

- The buildWidget method is where you build the interface
- The viewModelProvider method is where you provide your ViewModel provider.

Similar with the maac_mvvm, We don't need to worry about the other lifecycles of the widget because they will be called automatically 
corresponding to the ViewModel.

```dart
class ExamplePage extends ConsumerViewModelWidget<ExamplePageViewModel> {
  const ExamplePage({super.key});
  
  @override
  AutoDisposeProvider<ExamplePageViewModel> viewModelProvider() => exampleViewModelProvider;
  
  @override
  Widget buildWidget(BuildContext context, WidgetRef ref, ExamplePageViewModel viewModel) {
    return BuildYourPageWidget();
  }
}
```
In case the widget has properties passed in and we need to pass them to the ViewModel, we can override awake.

The awake method will be called immediately after the createViewModel method of ViewModelWidget and before the onInitState method of the ViewModel. This will be helpful for setting up the necessary data.
```dart
class ExamplePage extends ConsumerViewModelWidget<ExamplePageViewModel> {
  final int initValue;
  const ExamplePage({super.key, required this.initValue});

  @override
  AutoDisposeProvider<ExamplePageViewModel> viewModelProvider() => exampleViewModelProvider;

  @override
  void awake(WidgetRef ref, ExamplePageViewModel viewModel) => viewModel.setup(initValue);
  
  @override
  Widget buildWidget(BuildContext context, WidgetRef ref, ExamplePageViewModel viewModel) {
    return BuildYourPageWidget();
  }
}
```
### 4 - Listen to data changes from ViewModel
To listen to data changes from a ViewModel in Riverpod, we can use the components provided by Riverpod. 
Since Riverpod is a state management library, we can use the `StateController` provided by default in RiverViewModel 
called `uiState` to update the UI.

In the following example, ExamplePageViewModel will increase the counter and update the UI through `uiState`. 
The ViewModel will also expose `counterSelector` for the Widget to listen and update.
```dart
class ExamplePageViewModel extends RiverViewModel<ExamplePageUIState> {
  ExamplePageViewModel({required super.uiState});

  final counterSelector = _exampleUIStateProvider.select((value) => value.counter);

  void incrementCounter() {
    uiState.update((state) => state.copyWith(counter: state.counter + 1));
  }
}
```
You can use components provided by RiverPod, such as ConsumerWidget, to update the UI
```dart
class ExampleCounterText extends ConsumerWidget {
  const ExampleCounterText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(exampleViewModelProvider);
    final counter = ref.watch(viewModel.counterSelector);
    return Text(
      '$counter',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
```
### Full Example
```dart

class ExamplePage extends ConsumerViewModelWidget<ExamplePageViewModel> {
  const ExamplePage({super.key});

  @override
  AutoDisposeProvider<ExamplePageViewModel> viewModelProvider() => exampleViewModelProvider;

  @override
  Widget buildWidget(BuildContext context, WidgetRef ref, ExamplePageViewModel viewModel) {
    final counter = ref.watch(viewModel.counterSelector);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            // Listen to counterSelector to update UI
            Consumer(
              builder: (context, ref, child) {
                final counter = ref.watch(viewModel.counterSelector);
                return Text(
                  '$counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

final _exampleUIStateProvider = StateProvider.autoDispose<ExamplePageUIState>((ref) {
  return ExamplePageUIState();
});

final exampleViewModelProvider = Provider.autoDispose<ExamplePageViewModel>((ref) {
  return ExamplePageViewModel(uiState: ref.watch(_exampleUIStateProvider.notifier));
});

class ExamplePageUIState {
  int counter;

  ExamplePageUIState({this.counter = 0});

  ExamplePageUIState copyWith({int? counter}) {
    return ExamplePageUIState(
      counter: counter ?? this.counter,
    );
  }
}

class ExamplePageViewModel extends RiverViewModel<ExamplePageUIState> {
  ExamplePageViewModel({required super.uiState});
  // Expose a selector for Widget to listen and update
  final counterSelector = _exampleUIStateProvider.select((value) => value.counter);
  
  void incrementCounter() {
    // Update uiState to reflect the new counter value
    uiState.update((state) => state.copyWith(counter: state.counter + 1));
  }
}
```

### API:
ConsumerViewModelWidget
- `awake`
- `viewModelProvider`
- `buildWidget`

RiverViewModel
- `onInitState`
- `onResume`
- `onPause`
- `onDispose`
- `onApplicationResumed`
- `onApplicationInactive`
- `onApplicationPaused`
- `onApplicationDetached`

## Additional Information
Any PR is a great help. Thanks