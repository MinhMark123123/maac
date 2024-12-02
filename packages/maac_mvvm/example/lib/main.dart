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
  ExamplePageViewModel createViewModel() {
    return ExamplePageViewModel();
  }

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
            StreamDataConsumer<int>(
              builder: (context, data, child) {
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
      ),
    );
  }
}

class ExamplePageViewModel extends ViewModel {
  late final _uiState = 0.mutableData(this);
  late final uiState = _uiState.streamData;

  void incrementCounter() {
    _uiState.postValue(uiState.data + 1);
  }
}
