import 'dart:collection';
import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/src/view_model/life_cycle_component.dart';

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
///Please refer to [LifecycleComponent] for more information.
abstract class ViewModel with LifecycleComponent {
  final List<LifecycleComponent> _listLifeComponents = <LifecycleComponent>[];
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
    cancelByKey(requestKey);
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

  void cancelByKey(Key key) {
    if (_cancelableOperation.containsKey(key)) {
      _cancelableOperation[key]?.cancel();
      _cancelableOperation.remove(key);
    }
  }

  void addComponents(LifecycleComponent lifecycleComponent) {
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
