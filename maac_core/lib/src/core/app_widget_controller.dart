import 'package:flutter/widgets.dart';
import 'package:maac_core/src/core/app_controller.dart';

class AppWidgetController extends StatefulWidget {
  final Widget child;
  final List<AppController>? controllers;

  factory AppWidgetController.singleController({
    Key? key,
    required Widget child,
    required AppController controller,
  }) {
    return AppWidgetController(
      key: key,
      controllers: [controller],
      child: child,
    );
  }

  const AppWidgetController({
    Key? key,
    required this.child,
    this.controllers,
  }) : super(key: key);

  @override
  State<AppWidgetController> createState() => _AppWidgetControllerState();
}

class _AppWidgetControllerState extends State<AppWidgetController> {
  @override
  void initState() {
    widget.controllers?.forEach((element) {
      element.onInitState();
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.controllers?.forEach((element) {
      element.onDispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
