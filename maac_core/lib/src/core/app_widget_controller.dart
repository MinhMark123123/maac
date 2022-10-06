import 'package:flutter/widgets.dart';
import 'package:maac_core/src/core/app_controller.dart';

class View<T extends AppController> extends StatefulWidget {
  final Widget child;
  final T controller;
  final bool enableBindAppLifeCycle;
  final Function(T)? setup;

  const View({
    Key? key,
    required this.child,
    required this.controller,
    this.enableBindAppLifeCycle = false,
    this.setup,
  }) : super(key: key);

  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View> {
  @override
  void initState() {
    widget.setup?.call(widget.controller);
    if (widget.enableBindAppLifeCycle) {
      widget.controller.turnOnBindAppLifecycle();
    }
    widget.controller.onInitState();
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
