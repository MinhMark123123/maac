import 'dart:collection';
import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:maac_core/src/view_model/live_data/stream_data.dart';
import 'package:maac_core/src/view_model/view_model_life_cycle.dart';
import 'package:visibility_detector/src/visibility_detector.dart';

abstract class ViewModel extends ViewModelLifecycle with WidgetsBindingObserver {
  final List<StreamDataViewModel> _listStreamData = <StreamDataViewModel>[];
  bool _isFirstInit = true;
  bool _haseBeenDispose = false;

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
      onResume();
      onReady();
    });
    super.onInitState();
  }

  @override
  void onDispose() {
    _haseBeenDispose = true;
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
        onApplicationResumed();
        onResume();
        break;
      case AppLifecycleState.inactive:
        onApplicationInactive();
        break;
      case AppLifecycleState.paused:
        onPause();
        onApplicationPaused();
        break;
      case AppLifecycleState.detached:
        onApplicationDetached();
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

  void onVisibilityChanged(VisibilityInfo info) {
    final visibleFraction = info.visibleFraction;
    if (visibleFraction == 1) {
      //widget is appear
      if (!_isFirstInit) {
        onResume();
        return;
      }
      _isFirstInit = false;
      return;
    }
    if (visibleFraction == 0 && _haseBeenDispose == false) {
      //widget is not appear
      onPause();
    }
  }
}
