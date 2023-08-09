import 'dart:async';

import 'package:maac_mvvm/src/view_model/view_model.dart';

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
class StreamDataViewModel<T> extends StreamData<T> {
  StreamDataViewModel({
    required super.defaultValue,
    required ViewModel viewModel,
  }) {
    viewModel.addStreamData(this);
  }

  final StreamController<T> _controller = StreamController.broadcast();

  Sink<T> get _sink => _controller.sink;

  Stream<T> get _stream => _controller.stream;

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

  void close() => _controller.close();

  Future<bool> any(bool Function(T element) test) {
    return _stream.any(test);
  }

  Stream<T> asBroadcastStream({
    void Function(StreamSubscription<T> subscription)? onListen,
    void Function(StreamSubscription<T> subscription)? onCancel,
  }) {
    return _stream.asBroadcastStream(onListen: onListen, onCancel: onCancel);
  }
}
