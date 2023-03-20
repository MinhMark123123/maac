import 'package:flutter/widgets.dart';
import 'package:maac_core/src/foundations/executor.dart';
import 'package:maac_core/src/view_model/view_model_life_cycle.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LifeCycleManager with WidgetsBindingObserver {
  final List<ViewModelLifecycle> lifecycles;

  LifeCycleManager(this.lifecycles){
    print("LifeCycleManager ()");
  }

  Widget? _life;
  bool _isFirstInit = false;
  bool _hasBeenDispose = false;

  void registerWidgetBindLifecycle(Widget lifeOwner) {
    if (_life != null) return;
    _life = lifeOwner;
  }

  void _removeBindingWidgetObserver() {
    WidgetsBinding.instance.removeObserver(this);
  }

  bool isValidLifeCycleHolder(Widget lifeOwner) {
    if (_life == null) return false;
    return _life == lifeOwner;
  }

  void initState(Widget widget) {
    executeCondition(isValidLifeCycleHolder(widget), () {
      _isFirstInit = true;
      _bindWidgetLifeCycle();
      _doInitState();
      Future.delayed(Duration.zero, () => _doResume());
    });
  }

  void _doResume() {
    for (var element in lifecycles) {
      element.onResume();
    }
  }

  void _doInitState() {
    for (var element in lifecycles) {
      element.onInitState();
    }
  }

  void dispose(Widget widget) {
    executeCondition(isValidLifeCycleHolder(widget), () {
      _hasBeenDispose = true;
      _resetAppLifeCycleListener();
      _resetLife();
      _doDispose();
    });
  }

  void _doDispose() {
    for (var element in lifecycles) {
      element.onDispose();
    }
  }

  void onDeActive(Widget widget) {
    executeCondition(isValidLifeCycleHolder(widget), () {
      _doPause();
    });
  }

  void _doPause() {
    for (var element in lifecycles) {
      element.onPause();
    }
  }

  void onVisibilityChanged(VisibilityInfo info, Widget widget) {
    final visibleFraction = info.visibleFraction;
    if (visibleFraction == 1) {
      //widget is appear
      if (!_isFirstInit) {
        _doResume();
        return;
      }
      _isFirstInit = false;
      return;
    }
    if (visibleFraction == 0 && _hasBeenDispose == false) {
      //widget is not appear
      _doPause();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppLifecycleResume();

        break;
      case AppLifecycleState.inactive:
        _onAppLifecycleInActive();

        break;
      case AppLifecycleState.paused:
        _onAppLifecyclePause();

        break;
      case AppLifecycleState.detached:
        _onAppLifecycleDetached();
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  void _onAppLifecycleDetached() {
    for (var element in lifecycles) {
      element.onApplicationDetached();
    }
  }

  void _onAppLifecyclePause() {
    for (var element in lifecycles) {
      element.onPause();
      element.onApplicationPaused();
    }
  }

  void _onAppLifecycleInActive() {
    for (var element in lifecycles) {
      element.onApplicationInactive();
    }
  }

  void _onAppLifecycleResume() {
    for (var element in lifecycles) {
      element.onApplicationResumed();
      element.onResume();
    }
  }

  void _bindWidgetLifeCycle() {
    WidgetsBinding.instance.addObserver(this);
  }

  void _resetAppLifeCycleListener() {
    _removeBindingWidgetObserver();
  }

  void _resetLife() {
    _life = null;
  }
}
