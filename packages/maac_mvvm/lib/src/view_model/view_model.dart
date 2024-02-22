import 'dart:collection';
import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/src/view_model/stream_data/stream_data.dart';
import 'package:maac_mvvm/src/view_model/view_model_life_cycle.dart';

///A class that manages the logic state of a widget and binds it to the widget's lifecycle.
///
///### Lifecycle
///- onInitState
///- onResume
///- onPause
///- onDispose
///- onApplicationResumed
///- onApplicationInactive
///- onApplicationPaused
///- onApplicationDetached
///
///Please refer to [ViewModelLifecycle] for more information.
abstract class ViewModel extends ViewModelLifecycle {
  final List<ViewModelLifecycle> _listLifeComponents = <ViewModelLifecycle>[];
  final Map<Key, CancelableOperation> _cancelableOperation = HashMap();

  @override
  void onInitState() {
    _initStateComponent();
    markViewModelHasBondLifeCycle();
    super.onInitState();
  }

  @override
  void onDispose() {
    _cancelViewModelScope();
    _disposeComponent();
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

  void addComponents(ViewModelLifecycle lifecycleComponent) {
    _listLifeComponents.add(lifecycleComponent);
  }

  void _disposeComponent() {
    for (var element in _listLifeComponents) {
      element.onDispose();
    }
  }

  bool _isBoundLifeCycle = false;

  bool get isBoundLifeCycle => _isBoundLifeCycle;
  void markViewModelHasBondLifeCycle() {
    _isBoundLifeCycle = true;
  }

  void _initStateComponent() {
    for (var element in _listLifeComponents) {
      element.onInitState();
    }
  }
}
