import 'package:flutter/widgets.dart';
import 'package:maac_core/maac_core.dart';

abstract class ViewStatefulWidget<T extends ViewModel> extends StatefulWidget {
  const ViewStatefulWidget({
    Key? key,
  }) : super(key: key);

  @override
  ViewState createState();
}

abstract class ViewState<T extends ViewStatefulWidget> extends State<T> {
  late List<ViewModel> viewModels;

  void aWake(){}

  @override
  @mustCallSuper
  void initState() {
    viewModels = bindViewModels();
    aWake();
    for (var element in viewModels) {
      element.registerWidgetBindLifecycle(widget);
      executeCondition(element.isValidLifeCycleHolder(widget), () => element.onInitState());
    }
    super.initState();
  }

  @override
  @mustCallSuper
  void dispose() {
    for (var element in viewModels) {
      executeCondition(element.isValidLifeCycleHolder(widget), () => element.onDispose());
    }
    super.dispose();
  }

  List<ViewModel> bindViewModels();
}
