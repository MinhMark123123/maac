import 'dart:async';

import 'package:maac_mvvm/src/view_model/view_model.dart';

abstract class StreamData<T> {
  T _data;

  T get data => _data;

  StreamData({required T defaultValue}) : _data = defaultValue;

  Stream<T> asStream();
}

class StreamDataViewModel<T> extends StreamData<T> {

  StreamDataViewModel({required super.defaultValue, required ViewModel viewModel}) {
    viewModel.addStreamData(this);
  }

  final StreamController<T> _controller = StreamController.broadcast();

  Sink<T> get _sink => _controller.sink;

  Stream<T> get _stream => _controller.stream;

  void postValue(T data) {
    if (data == _data) return;
    _data = data;
    _sink.add(data);
  }

  void setValue(T data) {
    _data = data;
  }

  @override
  Stream<T> asStream() => _stream;

  void close() => _controller.close();
}
