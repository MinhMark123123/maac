import 'package:flutter/widgets.dart';
import 'package:maac_core/src/core/app_controller.dart';

class View extends StatefulWidget {
  final Widget child;
  final List<AppController>? controllers;

  factory View.singleController({
    Key? key,
    required Widget child,
    required AppController controllers,
  }) {
    return View(
      key: key,
      controllers: [controllers],
      child: child,
    );
  }

  const View({
    Key? key,
    required this.child,
    this.controllers,
  }) : super(key: key);

  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View> {
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
