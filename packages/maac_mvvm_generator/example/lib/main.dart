import 'package:example/example_view_model.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ViewModelWidget<ExampleViewModel> {
  const MyHomePage({super.key});

  @override
  ExampleViewModel createViewModel() => ExampleViewModel();

  @override
  Widget build(BuildContext context, ExampleViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Annotation"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            StreamDataConsumer(
              streamData: viewModel.count,
              builder: (context, data) {
                return Text(
                  '$data',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => viewModel.incrementCounter(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
