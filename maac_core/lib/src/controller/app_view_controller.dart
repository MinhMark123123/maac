import 'package:flutter/widgets.dart';
import 'package:maac_core/maac_core.dart';
import 'package:maac_core/src/controller/app_controller.dart';
import 'package:maac_core/src/controller/app_life_state.dart';

class View extends ViewStatefulWidget {
  final Widget child;

  const View({
    super.key,
    required super.controllers,
    required this.child,
    super.setup,
  });

  factory View.singleController({
    required AppController controller,
    required Widget child,
    bool enableBindAppLifeCycle = false,
    Function()? setup,
  }) {
    return View(
      controllers: [controller],
      setup: setup,
      child: child,
    );
  }

  @override
  ViewState<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends ViewState<View> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  List<AppController> get controllers => widget.controllers;

  @override
  Function()? get setup => widget.setup;
}