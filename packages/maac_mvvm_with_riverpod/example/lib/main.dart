import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_riverpod/maac_mvvm_with_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
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

class ExamplePage extends ConsumerViewModelWidget<ExamplePageViewModel> {
  const ExamplePage({super.key});

  @override
  AutoDisposeProvider<ExamplePageViewModel> viewModelProvider() => exampleViewModelProvider;

  @override
  Widget buildWidget(BuildContext context, WidgetRef ref, ExamplePageViewModel viewModel) {
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
        onPressed: viewModel.incrementCounter,// Call incrementCounter function in ViewModel
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
