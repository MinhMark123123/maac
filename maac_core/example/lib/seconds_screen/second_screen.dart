import 'package:example/seconds_screen/presentation/second_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:maac_core/maac_core.dart';

class SecondScreen extends ViewModelWidget<SecondScreenViewModel> {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context, SecondScreenViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          _buildCounterDisplay(viewModel),
          _buildButtonPlus(viewModel),
        ],
      ),
    );
  }

  Widget _buildButtonPlus(SecondScreenViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MaterialButton(
        onPressed: () {
          viewModel.increaseCounter();
        },
        child: const Text("+"),
      ),
    );
  }

  Expanded _buildCounterDisplay(SecondScreenViewModel viewModel) {
    return Expanded(
      child: Center(
        child: StreamDataConsumer(
          streamData: viewModel.uiState,
          builder: (context, data) {
            return Text("Your are pressed $data ");
          },
        ),
      ),
    );
  }

  @override
  SecondScreenViewModel createViewModel() => SecondScreenViewModel();
}
