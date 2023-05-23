import 'package:flutter/widgets.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

abstract class ViewStatefulWidget<T extends ViewModel> extends StatefulWidget {
  const ViewStatefulWidget({
    Key? key,
  }) : super(key: key);

  @override
  ViewState createState();
}

abstract class ViewState<T extends ViewStatefulWidget> extends State<T> {
  late List<ViewModel> viewModels;
  late LifeCycleManager _lifeCycleManager;

  LifeCycleManager get lifeCycleManager => _lifeCycleManager;

  void aWake() {}

  @override
  @mustCallSuper
  void initState() {
    viewModels = bindViewModels(context);
    aWake();
    _lifeCycleManager = LifeCycleManager(viewModels);
    _lifeCycleManager.registerWidgetBindLifecycle(widget);
    _lifeCycleManager.initState(widget);
    super.initState();
  }

  @override
  @mustCallSuper
  void dispose() {
    _lifeCycleManager.dispose(widget);
    super.dispose();
  }

  List<ViewModel> bindViewModels(BuildContext context);
}
