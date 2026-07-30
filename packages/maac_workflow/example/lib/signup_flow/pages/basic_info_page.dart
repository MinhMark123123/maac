import 'package:flutter/material.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

import '../signup_context.dart';
import '../signup_flow_view_model.dart';
import '../signup_step_ids.dart';
import 'signup_step_card.dart';

class BasicInfoViewModel extends ViewModel {
  final SignupFlowViewModel coordinator;
  BasicInfoViewModel(this.coordinator);

  late final emailController = TextEditingController(
    text: coordinator.context.email.isNotEmpty ? coordinator.context.email : 'test@maac.com',
  );
  late final passwordController = TextEditingController(
    text: coordinator.context.password.isNotEmpty ? coordinator.context.password : 'password123',
  );

  void submit() {
    coordinator.context.email = emailController.text;
    coordinator.context.password = passwordController.text;
    coordinator.workflowRunner.submit(SignupStepIds.basicInfo);
  }

  void abort() => coordinator.cancelWorkflow();

  @override
  void onDispose() {
    emailController.dispose();
    passwordController.dispose();
    super.onDispose();
  }
}

class BasicInfoPage extends ViewModelWidget<BasicInfoViewModel> {
  final SignupFlowViewModel coordinator;
  const BasicInfoPage({super.key, required this.coordinator});

  @override
  BasicInfoViewModel createViewModel() => BasicInfoViewModel(coordinator);

  @override
  Widget build(BuildContext context, BasicInfoViewModel viewModel) {
    return SignupStepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          signupWizardHeader(1, 'Basic Credentials', 'Input email & password to register.'),
          const SizedBox(height: 24),
          TextField(
            controller: viewModel.emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email Address',
              labelStyle: const TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: viewModel.passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
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
}
