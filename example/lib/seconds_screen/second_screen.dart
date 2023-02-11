import 'package:flutter/material.dart';
import 'package:example/seconds_screen/presentation/second_screen_view_model.dart';
import 'package:maac_with_riverpod/maac_with_riverpod.dart';

class SecondScreen extends ConsumerViewModelWidget<SecondScreenViewModel> {
  const SecondScreen({super.key});

  @override
  AutoDisposeProvider<SecondScreenViewModel> viewModelProvider() => secondScreenControllerProvider;

  @override
  Widget buildWidget(BuildContext context, WidgetRef ref, SecondScreenViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(),
      body: buildBody(ref),
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
              viewModel(ref).increaseCounter();
            },
            child: const Text("+"),
          ),
        )
      ],
    );
  }
}

class CounterText extends ConsumerViewModelWidget<SecondScreenViewModel> {

  const CounterText({Key? key}) : super(key: key);

  @override
  Widget buildWidget(BuildContext context, WidgetRef ref, SecondScreenViewModel viewModel) {
    final counterState = ref.watch(viewModel.counterChange);
    return Text("Your are pressed $counterState ");
  }

  @override
  AutoDisposeProvider<SecondScreenViewModel> viewModelProvider() => secondScreenControllerProvider;
}
