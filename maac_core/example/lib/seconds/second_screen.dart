import 'package:example/seconds/presentation/second_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maac_core/maac_core.dart';

class SecondScreen extends ConsumerWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return View<SecondScreenController>(
      controller: ref.read(secondScreenControllerProvider),
      child: Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text("second"),
        ),
      ),
    );
  }

/*
  @override
  Widget build(BuildContext context) {
    return View<SecondScreenController>(
      controller: SecondScreenController(),
      child: Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text("second"),
        ),
      ),
    );
  }*/
}
