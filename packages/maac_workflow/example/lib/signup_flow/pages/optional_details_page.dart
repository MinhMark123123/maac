import 'package:flutter/material.dart';
import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';

import '../signup_context.dart';
import '../signup_flow_view_model.dart';
import '../signup_step_ids.dart';
import 'signup_step_card.dart';

part 'optional_details_page.g.dart';

@BindableViewModel()
class OptionalDetailsViewModel extends ViewModel {
  final SignupFlowViewModel coordinator;
  OptionalDetailsViewModel(this.coordinator);

  @Bind()
  late final _selectedAvatar = StreamDataViewModel<String?>(defaultValue: null, viewModel: this);

  late final referralController = TextEditingController(text: coordinator.context.referralCode ?? '');

  void selectAvatar(String emoji) => _selectedAvatar.postValue(emoji);

  void submit() {
    coordinator.context.avatarUrl = _selectedAvatar.data;
    coordinator.context.referralCode = referralController.text;
    coordinator.workflowRunner.submit(SignupStepIds.optionalDetails);
  }

  void abort() => coordinator.cancelWorkflow();

  @override
  void onDispose() {
    referralController.dispose();
    super.onDispose();
  }
}

class OptionalDetailsPage extends ViewModelWidget<OptionalDetailsViewModel> {
  final SignupFlowViewModel coordinator;
  const OptionalDetailsPage({super.key, required this.coordinator});

  @override
  OptionalDetailsViewModel createViewModel() => OptionalDetailsViewModel(coordinator);

  @override
  Widget build(BuildContext context, OptionalDetailsViewModel viewModel) {
    return SignupStepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          signupWizardHeader(2, 'Personal Profile (Conditional Step)', 'Select a cute avatar and enter code.'),
          const SizedBox(height: 20),
          const Text(
            'Choose Avatar:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          StreamDataConsumer<String?>(
            streamData: viewModel.selectedAvatar,
            builder: (context, selected) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _avatarButton('🐱', 'Cat', selected, viewModel.selectAvatar),
                  _avatarButton('🐶', 'Dog', selected, viewModel.selectAvatar),
                  _avatarButton('🦊', 'Fox', selected, viewModel.selectAvatar),
                  _avatarButton('🦁', 'Lion', selected, viewModel.selectAvatar),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          TextField(
            controller: viewModel.referralController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Referral Code (Optional)',
              labelStyle: const TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
            ),
          ),
          const Spacer(),
          signupNavigationRow(onAbort: viewModel.abort, onSubmit: viewModel.submit),
        ],
      ),
    );
  }

  Widget _avatarButton(String emoji, String name, String? selected, void Function(String) onSelect) {
    final isSelected = selected == emoji;
    return GestureDetector(
      onTap: () => onSelect(emoji),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyanAccent.withValues(alpha: 0.15) : const Color(0xFF22222E),
          border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(color: isSelected ? Colors.cyanAccent : Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
