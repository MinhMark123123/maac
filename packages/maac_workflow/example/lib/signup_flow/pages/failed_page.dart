import 'package:flutter/material.dart';

import '../signup_flow_view_model.dart';
import 'signup_step_card.dart';

/// Purely presentational — the "Go Home" action now lives in
/// `SignupFlowShell`'s header, so this page only renders the outcome.
class FailedPage extends StatelessWidget {
  final SignupFlowViewModel coordinator;
  const FailedPage({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    return const SignupStepCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
          SizedBox(height: 24),
          Text('Signup Flow Failed / Cancelled!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'The workflow halted. Any database account creation was fully deleted and rolled back as verified in telemetry.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
