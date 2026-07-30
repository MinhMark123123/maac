import 'package:flutter/material.dart';

import '../signup_context.dart';
import '../signup_flow_view_model.dart';
import 'signup_step_card.dart';

/// Purely presentational — the "Go Home" action now lives in
/// `SignupFlowShell`'s header, so this page only renders the outcome.
class SuccessPage extends StatelessWidget {
  final SignupFlowViewModel coordinator;
  const SuccessPage({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    return SignupStepCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.greenAccent),
          const SizedBox(height: 24),
          const Text('Signup Flow Succeeded!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('User database record successfully completed with ID: ${coordinator.context.userId}', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
