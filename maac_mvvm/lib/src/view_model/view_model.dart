import 'dart:collection';
import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/src/view_model/stream_data/stream_data.dart';
import 'package:maac_mvvm/src/view_model/view_model_life_cycle.dart';

abstract class ViewModel extends ViewModelLifecycle {
  final List<StreamDataViewModel> _listStreamData = <StreamDataViewModel>[];
  final Map<Key, CancelableOperation> _cancelableOperation = HashMap();

  @override
  void onInitState() {
    markViewModelHasBondLifeCycle();
    super.onInitState();
  }
  @override
  void onDispose() {
    _cancelViewModelScope();
    _closeStreamData();
    super.onDispose();
  }

  Future<G> viewModelScope<G>(Future<G> Function() future, {Key? key}) async {
    final requestKey = key ?? UniqueKey();
    _cancelByKey(requestKey);
    final cancelable = CancelableOperation<G>.fromFuture(
      future(),
    );
    _cancelableOperation[requestKey] = cancelable;
    return await cancelable.value;
  }

  void _cancelViewModelScope() {
    for (final element in _cancelableOperation.values) {
      element.cancel();
    }
    _cancelableOperation.clear();
  }

  void _cancelByKey(Key key) {
    if (_cancelableOperation.containsKey(key)) {
      _cancelableOperation[key]?.cancel();
      _cancelableOperation.remove(key);
    }
  }

  void addStreamData(StreamDataViewModel streamDataViewModel) {
    _listStreamData.add(streamDataViewModel);
  }

  void _closeStreamData() {
    for (var element in _listStreamData) {
      element.close();
    }
  }
  bool _isBoundLifeCycle = false;

  bool get isBoundLifeCycle => _isBoundLifeCycle;
  void markViewModelHasBondLifeCycle() {
    _isBoundLifeCycle = true;
  }
}
