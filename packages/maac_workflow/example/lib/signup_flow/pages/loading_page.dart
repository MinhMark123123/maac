import 'package:flutter/material.dart';

import 'signup_step_card.dart';

/// Purely presentational — no local state, so no ViewModel needed.
class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignupStepCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent)),
          SizedBox(height: 24),
          Text('Backend Orchestration Running...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('The workflow runner is performing background API transaction checks.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
