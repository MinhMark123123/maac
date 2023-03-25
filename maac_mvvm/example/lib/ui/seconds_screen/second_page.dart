import 'package:flutter/material.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'view_models/second_page_view_model.dart';

class SecondPage extends ViewModelWidget<SecondScreenViewModel> {
  const SecondPage({super.key});

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
