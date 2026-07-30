import 'package:flutter/material.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

import '../signup_flow_view_model.dart';
import 'signup_step_card.dart';

class WelcomeViewModel extends ViewModel {
  final SignupFlowViewModel coordinator;
  WelcomeViewModel(this.coordinator);

  StreamData<bool> get needsOptional => coordinator.needsOptional;
  StreamData<bool> get forceFail => coordinator.forceFail;

  void setNeedsOptional(bool value) => coordinator.setNeedsOptional(value);
  void setForceFail(bool value) => coordinator.setForceFail(value);
  void launch() => coordinator.startFlow();
}

class WelcomePage extends ViewModelWidget<WelcomeViewModel> {
  final SignupFlowViewModel coordinator;
  const WelcomePage({super.key, required this.coordinator});

  @override
  WelcomeViewModel createViewModel() => WelcomeViewModel(coordinator);

  @override
  Widget build(BuildContext context, WelcomeViewModel viewModel) {
    return SignupStepCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle_outlined, size: 80, color: Colors.cyanAccent),
          const SizedBox(height: 16),
          const Text(
            'Interactive Stepper Wizard',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This wizard simulates interactive user input screens driven by the workflow pipeline. We can enable/disable steps, force step failures to trigger transactions and rollback account deletion.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),
          StreamDataConsumer<bool>(
            streamData: viewModel.needsOptional,
            builder: (context, opt) {
              return SwitchListTile(
                title: const Text('Enable Step 2: Avatar & Referral (Conditional Step)', style: TextStyle(color: Colors.white)),
                subtitle: const Text('If off, this step will be marked Skipped by the engine.', style: TextStyle(color: Colors.grey)),
                value: opt,
                onChanged: viewModel.setNeedsOptional,
                activeColor: Colors.cyanAccent,
              );
            },
          ),
          StreamDataConsumer<bool>(
            streamData: viewModel.forceFail,
            builder: (context, fail) {
              return SwitchListTile(
                title: const Text('Force Register API to Fail (Trigger LIFO Rollback)', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Forces final step to crash. This deletes the created user account.', style: TextStyle(color: Colors.grey)),
                value: fail,
                onChanged: viewModel.setForceFail,
                activeColor: Colors.cyanAccent,
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: viewModel.launch,
            child: const Text('Launch Signup Flow', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
