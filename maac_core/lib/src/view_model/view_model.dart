import 'dart:collection';
import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:maac_core/src/view_model/live_data/stream_data.dart';
import 'package:maac_core/src/view_model/view_model_life_cycle.dart';

abstract class ViewModel extends ViewModelLifecycle with WidgetsBindingObserver {
  final List<StreamDataViewModel> _listStreamData = <StreamDataViewModel>[];

  bool enableBindAppLifeCycle() {
    return false;
  }

  bool get _enableBindAppLifeCycle => enableBindAppLifeCycle();

  final Map<Key, CancelableOperation> _cancelableOperation = HashMap();
  Widget? _life;

  void registerWidgetBindLifecycle(Widget lifeOwner) {
    if (_life != null) return;
    _life = lifeOwner;
  }

  bool isValidLifeCycleHolder(Widget lifeOwner) {
    if (_life == null) return false;
    return _life == lifeOwner;
  }

  @override
  void onInitState() {
    if (_enableBindAppLifeCycle) {
      _bindWidgetLifeCycle();
    }
    Future.delayed(Duration.zero, () {
      if (_enableBindAppLifeCycle) {
        onResumed();
      }
      onReady();
    });
    super.onInitState();
  }

  @override
  void onDispose() {
    _resetLife();
    _cancelViewModelScope();
    _resetAppLifeCycleListener();
    _closeStreamData();
    super.onDispose();
  }

  void _resetAppLifeCycleListener() {
    if (_enableBindAppLifeCycle) {
      _removeBindingWidgetObserver();
    }
  }

  void _resetLife() {
    _life = null;
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.paused:
        onPaused();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  void _bindWidgetLifeCycle() {
    WidgetsBinding.instance.addObserver(this);
  }

  void _removeBindingWidgetObserver() {
    WidgetsBinding.instance.removeObserver(this);
  }

  void addStreamData(StreamDataViewModel streamDataViewModel) {
    _listStreamData.add(streamDataViewModel);
  }

  void _closeStreamData() {
    for (var element in _listStreamData) {
      element.close();
    }
  }
}
