import 'package:example/seconds_screen/presentation/second_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maac_core/maac_core.dart';

class SecondScreen extends ConsumerWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return View.singleController(
      controller: ref.read(secondScreenControllerProvider),
      child: Scaffold(
        appBar: AppBar(),
        body: buildBody(ref),
      ),
    );
  }

  Widget buildBody(WidgetRef ref) {
    return Column(
      children: [
        const Expanded(child: Center(child: CounterText())),
        Padding(
          padding: const EdgeInsets.all(16),
          child: MaterialButton(
            onPressed: () {
              ref.read(secondScreenControllerProvider).increaseCounter();
            },
            child: const Text("+"),
          ),
        )
      ],
    );
  }
}

class CounterText extends ConsumerWidget {
  const CounterText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterState = ref.watch(ref.read(secondScreenControllerProvider).ui);
    return Text("Your are pressed ${counterState.counter} ");
  }
}