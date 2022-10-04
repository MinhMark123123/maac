import 'package:example/seconds/second_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:maac_core/maac_core.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppWidgetController.singleController(
      controller:SecondScreenController(),
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            '0',
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){},
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This
      ),
    );
  }
}
