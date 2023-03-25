import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_riverpod/maac_mvvm_with_riverpod.dart';
import 'presentation/second_screen_view_model.dart';

class SecondPage extends ConsumerViewModelWidget<SecondScreenViewModel> {
  const SecondPage({super.key});

  @override
  AutoDisposeProvider<SecondScreenViewModel> viewModelProvider() => secondScreenViewModelProvider;

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
  AutoDisposeProvider<SecondScreenViewModel> viewModelProvider() => secondScreenViewModelProvider;
}
