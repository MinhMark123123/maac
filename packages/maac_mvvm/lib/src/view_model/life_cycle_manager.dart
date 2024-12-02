import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/src/foundations/executor.dart';
import 'package:maac_mvvm/src/view_model/life_cycle_component.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LifeCycleManager with WidgetsBindingObserver {
  final List<LifecycleComponent> lifecycles;

  LifeCycleManager(this.lifecycles);

  String? _lifeOwnerKey;
  bool _isFirstInit = false;
  bool _hasBeenDispose = false;

  void registerWidgetBindLifecycle(String lifeOwnerKey) {
    if (_lifeOwnerKey != null) return;
    _lifeOwnerKey = lifeOwnerKey;
  }

  void _removeBindingWidgetObserver() {
    WidgetsBinding.instance.removeObserver(this);
  }

  bool isValidLifeCycleHolder(String lifeOwnerKey) {
    if (_lifeOwnerKey == null) return false;
    return _lifeOwnerKey == lifeOwnerKey;
  }

  void initState(String lifeOwnerKey) {
    executeCondition(isValidLifeCycleHolder(lifeOwnerKey), () {
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

  void dispose(String lifeOwnerKey) {
    executeCondition(isValidLifeCycleHolder(lifeOwnerKey), () {
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
    _onDisposeSubscribes?.forEach((e) => e.call());
  }

  void _doPause() {
    for (var element in lifecycles) {
      element.onPause();
    }
  }

  void onVisibilityChanged(VisibilityInfo info) {
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
      case AppLifecycleState.hidden:
        _onAppLifecycleHidden();
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

  void _onAppLifecycleHidden() {
    for (var element in lifecycles) {
      element.onPause();
      element.onApplicationHidden();
    }
  }

  void _bindWidgetLifeCycle() {
    WidgetsBinding.instance.addObserver(this);
  }

  void _resetAppLifeCycleListener() {
    _removeBindingWidgetObserver();
  }

  void _resetLife() {
    _lifeOwnerKey = null;
  }

  List<Function()>? _onActiveSubscribes;
  List<Function()>? _onOnDeActiveSubscribes;
  List<Function()>? _onDidChangeDependenciesSubscribes;
  List<Function<T extends Widget>(T oldWidget)>? _onDidUpdateSubscribes;
  List<Function()>? _onDisposeSubscribes;

  void onActive(Function() actionOnActive) {
    _onActiveSubscribes ??= [];
    _onActiveSubscribes?.add(actionOnActive);
  }

  void onDeActive(Function() actionOnDeActive) {
    _onOnDeActiveSubscribes ??= [];
    _onOnDeActiveSubscribes?.add(actionOnDeActive);
  }

  void onDidChangeDependencies(
    Function() actionOnDidChangeDependencies,
  ) {
    _onDidChangeDependenciesSubscribes ??= [];
    _onDidChangeDependenciesSubscribes?.add(actionOnDidChangeDependencies);
  }

  void onDidUpdate(
    Function<T extends Widget>(T oldWidget) actionOnDidUpdate,
  ) {
    _onDidUpdateSubscribes ??= [];
    _onDidUpdateSubscribes?.add(actionOnDidUpdate);
  }

  void onDispose(Function() actionOnDispose) {
    _onDisposeSubscribes ??= [];
    _onDisposeSubscribes?.add(actionOnDispose);
  }

  void widgetActivate(String lifeOwnerKey) {
    executeCondition(isValidLifeCycleHolder(lifeOwnerKey), () {
      _onActiveSubscribes?.forEach((a) => a.call());
    });
  }

  void widgetDeActivate(String lifeOwnerKey) {
    executeCondition(isValidLifeCycleHolder(lifeOwnerKey), () {
      _onOnDeActiveSubscribes?.forEach((a) => a.call());
    });
  }

  void widgetDidChangeDependencies(String lifeOwnerKey) {
    executeCondition(isValidLifeCycleHolder(lifeOwnerKey), () {
      _onDidChangeDependenciesSubscribes?.forEach((a) => a.call());
    });
  }

  void widgetDidUpdateWidget<T extends Widget>({
    required String lifeOwnerKey,
    required Widget widget,
    required covariant T oldWidget,
  }) {
    executeCondition(isValidLifeCycleHolder(lifeOwnerKey), () {
      _onDidUpdateSubscribes?.forEach((a) => a.call(oldWidget));
    });
  }
}
