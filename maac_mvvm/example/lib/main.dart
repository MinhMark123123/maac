import 'package:flutter/material.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

void main() {
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

class ExamplePage extends ViewModelWidget<ExamplePageViewModel> {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context, ExamplePageViewModel viewModel) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
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
        onPressed: viewModel.incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  ExamplePageViewModel createViewModel(BuildContext context) => ExamplePageViewModel();
}

class ExamplePageViewModel extends ViewModel {
  late final StreamDataViewModel<int> _uiState = StreamDataViewModel(
    defaultValue: 0,
    viewModel: this,
  );

  StreamData<int> get uiState => _uiState;

  void incrementCounter() {
    _uiState.postValue(_uiState.data + 1);
  }
}
