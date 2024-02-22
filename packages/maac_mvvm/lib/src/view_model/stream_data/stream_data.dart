import 'dart:async';

import 'package:async/async.dart';
import 'package:maac_mvvm/src/view_model/view_model.dart';
import 'package:maac_mvvm/src/view_model/view_model_life_cycle.dart';

/// A StreamData class used when updating data state from ViewModel to Widget.
///
///- [StreamData] is usually used to expose data from ViewModel to Widget, so it
/// does not have methods for updating or modifying data.
///
///- [StreamData] will automatically cancel when the ViewModel falls into [onDispose].
///
///** Usage in ViewModel:
///
///```dart
///class ExamplePageViewModel extends ViewModel {
///   ExamplePageViewModel();
///
///   late final StreamDataViewModel<int> _uiState = StreamDataViewModel(
///     defaultValue: 0,
///     viewModel: this,
///   );
///
///   StreamData<int> get uiState => _uiState;
///
///   void increaseCounter() {
///     _uiState.postValue(_uiState.data + 1);
///   }
/// }
///```
///
///** Usage in Widget:
///
/// ```dart
/// StreamDataConsumer<int>(
///   streamData: viewModel.uiState,
///   builder: (context, data) {
///     return Text("You have pressed the button $data times.");
///   },
/// )
/// ```
abstract class StreamData<T> {
  T _data;

  /// Access the data value that StreamData is holding.
  T get data => _data;

  StreamData({required T defaultValue}) : _data = defaultValue;

  /// [asStream] returns a stream to listen to with [listen] or use
  /// with [StreamDataConsumer].
  Stream<T> asStream();
}

/// The StreamDataViewModel class is used when initializing [StreamData] while binding it with ViewModel.
///
/// [StreamDataViewModel] will automatically cancel when the ViewModel falls into [onDispose].
///
/// Support 2 methods to update data state: [postValue] and [setValue].
///
///** Usage in ViewModel:
///
///```dart
///class ExamplePageViewModel extends ViewModel {
///   ExamplePageViewModel();
///
///   late final StreamDataViewModel<int> _uiState = StreamDataViewModel(
///     defaultValue: 0,
///     viewModel: this,
///   );
///
///   StreamData<int> get uiState => _uiState;
///
///   void increaseCounter() {
///     _uiState.postValue(_uiState.data + 1);
///   }
/// }
///```
class StreamDataViewModel<T> extends StreamData<T> with ViewModelLifecycle {
  late final ViewModel _viewModel;
  StreamDataViewModel({
    required super.defaultValue,
    required ViewModel viewModel,
  }) {
    _viewModel = viewModel;
    viewModel.addComponents(this);
  }

  final StreamController<T> _controller = StreamController.broadcast();

  Sink<T> get _sink => _controller.sink;

  Stream<T> get _stream => _controller.stream;
  final List<StreamSubscription> _sourcesSub = [];


  /// Update [data] while notifying the Widget or listener of the update via stream.
  void postValue(T data) {
    if (data == _data) return;
    _data = data;
    if (_controller.isClosed) return;
    _sink.add(data);
  }

  /// Only update [data] silently.
  void setValue(T data) {
    _data = data;
  }

  @override
  Stream<T> asStream() => _stream;

  @override
  void onDispose() {
    _controller.close();
    for (var element in _sourcesSub) {
      element.cancel();
    }
    super.onDispose();
  }

  Future<bool> any(bool Function(T element) test) {
    return _stream.any(test);
  }

  Stream<T> asBroadcastStream({
    void Function(StreamSubscription<T> subscription)? onListen,
    void Function(StreamSubscription<T> subscription)? onCancel,
  }) {
    return _stream.asBroadcastStream(onListen: onListen, onCancel: onCancel);
  }

  StreamData<R> map<R>({
    required R Function(T data) mapper,
  }) {
    final stream = this.asStream();
    final mapperStream = stream.map((event) => mapper(event));
    final mapMutableData = StreamDataViewModel(defaultValue: mapper(_data), viewModel: _viewModel);
    _sourcesSub.add(mapperStream.listen((event) => mapMutableData.postValue(event)));
    return mapMutableData;
  }
}

class MediatorStreamData<T> extends StreamDataViewModel<T> {
  final List<StreamSubscription> _sourcesSub = [];

  MediatorStreamData({
    required super.defaultValue,
    required ViewModel viewModel,
  }) : super(viewModel: viewModel) {
    viewModel.addComponents(this);
  }

  void addSource<G>(Stream<G> source, void Function(G data) onData) {
    _sourcesSub.add(source.listen((event) => onData(event)));
  }

  @override
  void onDispose() {
    for (var element in _sourcesSub) {
      element.cancel();
    }
    super.onDispose();
  }
}
