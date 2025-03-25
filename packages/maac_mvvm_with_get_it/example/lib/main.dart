import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

// This is our global ServiceLocator
GetIt sl = GetIt.instance;
var inject = GetIt.instance;

void setupGetIt() {
  sl.registerSingleton(const SimpleRepository());
}

void registerViewModels() {
  registerViewModel(() => ExamplePageViewModel());
  registerViewModel(() => ExampleAPageViewModel());
  registerViewModel(() => ExampleBPageViewModel(repository: inject()));
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

class ExamplePage extends DependencyViewModelWidget<ExamplePageViewModel> {
  const ExamplePage({super.key});

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
              streamData: viewModel.uiState,
              builder: (context, data) {
                return Text(
                  '$data',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            ElevatedButton(
              onPressed: () => _navigateTo(context, const ExampleAPage()),
              child: const Text("Move to A"),
            ),
            ElevatedButton(
              onPressed: () => _navigateTo(context, const ExampleBPage()),
              child: const Text("Move to B"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: sl.get<ExamplePageViewModel>().incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<dynamic> _navigateTo(BuildContext context, Widget page) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class ExampleAPage extends DependencyViewModelWidget<ExampleAPageViewModel> {
  const ExampleAPage({super.key});

  @override
  Widget build(BuildContext context, ExampleAPageViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: const Text("A")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            StreamDataConsumer(
              builder: (
                context,
                data,
              ) {
                return Text(
                  "$data",
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
              streamData: viewModel.uiState,
            ),
            StreamDataConsumer(
              builder: (
                context,
                data,
              ) {
                return Text(
                  data,
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
              streamData: viewModel.uiStateMap,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: sl.get<ExampleAPageViewModel>().incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ExampleBPage extends DependencyViewModelWidget<ExampleBPageViewModel> {
  const ExampleBPage({super.key});

  @override
  Widget build(BuildContext context, ExampleBPageViewModel viewModel) {
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
        onPressed: sl.get<ExampleBPageViewModel>().incrementCounter,
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

class ExampleAPageViewModel extends ViewModel {
  late final _uiState = 0.mutableData(this);

  StreamData<int> get uiState => _uiState;

  StreamData<String> get uiStateMap => _uiState.map(
        mapper: (data) => "${data + 3}",
      );

  void incrementCounter() {
    _uiState.postValue(_uiState.data + 1);
  }
}

class ExampleBPageViewModel extends ViewModel {
  final SimpleRepository _repository;

  ExampleBPageViewModel({required SimpleRepository repository})
      : _repository = repository;

  late final _uiState = 0.mutableData(this);

  StreamData<int> get uiState => _uiState.streamData;

  late final _dataApi = "".mutableData(this);

  StreamData<String> get dataApi => _dataApi.streamData;

  @override
  void onInitState() {
    super.onInitState();
    Future.delayed(Duration.zero, () {
      _repository.fakeFetch().then((data) => _dataApi.postValue(data));
    });
  }

  void incrementCounter() {
    _uiState.postValue(_uiState.data + 1);
  }
}

class SimpleRepository {
  const SimpleRepository();

  Future<String> fakeFetch() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return "Hello there!";
  }
}
