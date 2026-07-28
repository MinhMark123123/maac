import 'package:flutter/material.dart';

/// Shared card chrome every step page renders itself inside, matching the
/// visual style the wizard used before the per-step page split.
class SignupStepCard extends StatelessWidget {
  final Widget child;
  const SignupStepCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF181822),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      elevation: 8,
      child: Padding(padding: const EdgeInsets.all(28.0), child: child),
    );
  }
}

/// Shared "STEP n of 3 — title" header used by the interactive form steps.
Widget signupWizardHeader(int step, String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('STEP $step OF 3', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.w600, letterSpacing: 1.2, fontSize: 12)),
      const SizedBox(height: 4),
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      const SizedBox(height: 12),
      const Divider(color: Colors.white10),
    ],
  );
}

/// Shared bottom navigation row (Abort / Next-or-Submit) used by the
/// interactive form steps.
Widget signupNavigationRow({required VoidCallback onAbort, required VoidCallback onSubmit, bool isFinal = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      TextButton.icon(
        onPressed: onAbort,
        icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
        label: const Text('Abort Flow', style: TextStyle(color: Colors.redAccent)),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isFinal ? Colors.greenAccent : Colors.cyanAccent,
          foregroundColor: Colors.black,
          minimumSize: const Size(140, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onSubmit,
        child: Text(isFinal ? 'Final Submit' : 'Next Step', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    ],
  );
}
