import 'package:flutter/material.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'view_models/second_page_view_model.dart';

class SecondPage extends ViewModelWidget<SecondPageViewModel> {


  const SecondPage({super.key});

  @override
  SecondPageViewModel createViewModel(BuildContext context) => SecondPageViewModel();
@override
  void awake(BuildContext context, SecondPageViewModel viewModel) {
    // TODO: implement awake
    super.awake(context, viewModel);
  }

  @override
  Widget build(BuildContext context, SecondPageViewModel viewModel) {
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

  Widget _buildButtonPlus(SecondPageViewModel viewModel) {
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

  Expanded _buildCounterDisplay(SecondPageViewModel viewModel) {
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
}
