import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

abstract class ViewStatefulWidget extends StatefulWidget {
  const ViewStatefulWidget({
    Key? key,
  }) : super(key: key);

  @override
  ViewState createState();
}

abstract class ViewState<T extends ViewStatefulWidget> extends State<T> {
  List<ViewModel>? _viewModels;
  LifeCycleManager? _lifeCycleManager;
  final String _uniqueKey = UniqueKey().toString();
  String get uniqueKey => _uniqueKey;

  List<ViewModel> get viewModels {
    _viewModels ??= bindViewModels();
    return _viewModels!;
  }

  LifeCycleManager get lifeCycleManager {
    _lifeCycleManager ??= LifeCycleManager(viewModels);
    return _lifeCycleManager!;
  }

  void aWake() {}

  @override
  void activate() {
    lifeCycleManager.widgetActivate(_uniqueKey);
    super.activate();
  }

  @override
  void deactivate() {
    lifeCycleManager.widgetDeActivate(_uniqueKey);
    super.deactivate();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    lifeCycleManager.widgetDidUpdateWidget(
      lifeOwnerKey: _uniqueKey,
      widget: widget,
      oldWidget: oldWidget,
    );
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    lifeCycleManager.widgetDidChangeDependencies(_uniqueKey);
    super.didChangeDependencies();
  }

  @override
  @mustCallSuper
  void initState() {
    aWake();
    lifeCycleManager.registerWidgetBindLifecycle(_uniqueKey);
    lifeCycleManager.initState(_uniqueKey);
    super.initState();
  }

  @override
  @mustCallSuper
  void dispose() {
    lifeCycleManager.dispose(_uniqueKey);
    super.dispose();
  }

  List<ViewModel> bindViewModels();
}
