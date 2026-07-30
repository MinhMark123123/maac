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
      appBar: AppBar(
        title: const Text('maac_mvvm Example'),
        actions: [
          // StreamDataConsumer: a single StreamData<bool> drives the icon.
          StreamDataConsumer<bool>(
            streamData: viewModel.isFavoriteState,
            builder: (context, isFavorite) => IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: viewModel.toggleFavorite,
              tooltip: 'Toggle favorite',
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            StreamDataConsumer<int>(
              builder: (context, data) {
                return Text(
                  '$data',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
              streamData: viewModel.uiState,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: viewModel.toggleTheme,
              child: StreamDataConsumer<String>(
                streamData: viewModel.themeLabelState,
                builder: (context, theme) => Text('Theme: $theme (tap to toggle)'),
              ),
            ),
            const Divider(height: 48),
            const Text('Combining multiple StreamData sources at once:'),
            const SizedBox(height: 12),
            // StreamDataConsumer2: rebuilds whenever the counter OR the
            // favorite flag changes, with both latest values typed in the
            // builder — no manual combining needed.
            StreamDataConsumer2<int, bool>(
              streamData1: viewModel.uiState,
              streamData2: viewModel.isFavoriteState,
              builder: (context, count, isFavorite) {
                return Text('StreamDataConsumer2 → count=$count, favorite=$isFavorite');
              },
            ),
            // StreamDataConsumer3: same idea, one more source.
            StreamDataConsumer3<int, bool, String>(
              streamData1: viewModel.uiState,
              streamData2: viewModel.isFavoriteState,
              streamData3: viewModel.themeLabelState,
              builder: (context, count, isFavorite, theme) {
                return Text('StreamDataConsumer3 → count=$count, favorite=$isFavorite, theme=$theme');
              },
            ),
            // MergeStreamDataConsumer: the primitive Consumer2/3 are built
            // on. It only signals "something changed, rebuild" — read
            // whichever StreamData.data you need directly in the builder.
            MergeStreamDataConsumer(
              streams: [viewModel.uiState, viewModel.isFavoriteState, viewModel.themeLabelState],
              builder: (context) {
                return Text(
                  'MergeStreamDataConsumer → count=${viewModel.uiState.data}, '
                  'favorite=${viewModel.isFavoriteState.data}, theme=${viewModel.themeLabelState.data}',
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
      ),
    );
  }
}

class ExamplePageViewModel extends ViewModel {
  late final _uiState = 0.mutableData(this);
  late final uiState = _uiState.streamData;

  late final _isFavoriteState = false.mutableData(this);
  late final isFavoriteState = _isFavoriteState.streamData;

  late final _themeLabelState = 'Light'.mutableData(this);
  late final themeLabelState = _themeLabelState.streamData;

  void incrementCounter() {
    _uiState.postValue(uiState.data + 1);
  }

  void toggleFavorite() {
    _isFavoriteState.postValue(!isFavoriteState.data);
  }

  void toggleTheme() {
    _themeLabelState.postValue(themeLabelState.data == 'Light' ? 'Dark' : 'Light');
  }
}
