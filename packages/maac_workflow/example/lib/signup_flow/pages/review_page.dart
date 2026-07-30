import 'package:flutter/material.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

import '../signup_context.dart';
import '../signup_flow_view_model.dart';
import '../signup_step_ids.dart';
import 'signup_step_card.dart';

class ReviewViewModel extends ViewModel {
  final SignupFlowViewModel coordinator;
  ReviewViewModel(this.coordinator);

  StreamData<bool> get forceFail => coordinator.forceFail;

  void setForceFail(bool value) => coordinator.setForceFail(value);
  void submit() => coordinator.workflowRunner.submit(SignupStepIds.submitRegistration);
  void abort() => coordinator.cancelWorkflow();
}

class ReviewPage extends ViewModelWidget<ReviewViewModel> {
  final SignupFlowViewModel coordinator;
  const ReviewPage({super.key, required this.coordinator});

  @override
  ReviewViewModel createViewModel() => ReviewViewModel(coordinator);

  @override
  Widget build(BuildContext context, ReviewViewModel viewModel) {
    final ctx = viewModel.coordinator.context;
    return SignupStepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          signupWizardHeader(3, 'Final Submission', 'Review account credentials and finalize registration.'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                _infoRow('Email Address:', ctx.email),
                _infoRow('Assigned Database ID:', ctx.userId ?? 'Waiting...'),
                _infoRow('Chosen Avatar:', ctx.avatarUrl ?? 'None selected'),
                _infoRow('Referral Applied:', ctx.referralCode ?? 'None applied'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StreamDataConsumer<bool>(
            streamData: viewModel.forceFail,
            builder: (context, fail) {
              return SwitchListTile(
                title: const Text('Force Register API to Fail', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text(
                  'Will trigger LIFO Rollback. Watch it delete the user database ID!',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                value: fail,
                onChanged: viewModel.setForceFail,
                activeColor: Colors.cyanAccent,
              );
            },
          ),
          const Spacer(),
          signupNavigationRow(onAbort: viewModel.abort, onSubmit: viewModel.submit, isFinal: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
