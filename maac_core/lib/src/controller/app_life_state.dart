import 'package:flutter/widgets.dart';
import 'package:maac_core/maac_core.dart';

abstract class ViewStatefulWidget<T extends AppController> extends StatefulWidget {
  final List<T> controllers;
  final bool enableBindAppLifeCycle;
  final Function()? setup;

  const ViewStatefulWidget({
    Key? key,
    required this.controllers,
    this.enableBindAppLifeCycle = false,
    this.setup,
  }) : super(key: key);

  @override
  ViewState createState();
}

abstract class ViewState<T extends StatefulWidget> extends State<T> {
  @override
  @mustCallSuper
  void initState() {
    setup?.call();
    for (var element in controllers) {
      if (isEnableBindAppLifeCycle) {
        element.turnOnBindAppLifecycle();
      }
      element.onInitState();
    }
    super.initState();
  }

  @override
  @mustCallSuper
  void dispose() {
    for (var element in controllers) {
      element.onDispose();
    }
    super.dispose();
  }

  bool get isEnableBindAppLifeCycle;

  Function()? get setup;

  List<AppController> get controllers;
}
