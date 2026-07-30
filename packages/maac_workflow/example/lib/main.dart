import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import 'app.dart';
import 'di/service_locator.dart';

void main() async {
  registerViewModels();
  await _tinyWorkflowExample();
  runApp(const MyApp());
}

/// See the "Basics" section in-app for a full tour of the package.
Future<void> _tinyWorkflowExample() async {
  final runner = WorkflowRunner<FlowContext>(
    steps: [
      WorkflowStep<FlowContext>.action(
        id: 'say_hello',
        execute: (context, token) async {
          debugPrint('Hello from maac_workflow!');
          return const StepSuccess();
        },
      ),
    ],
  );
  final result = await runner.run(FlowContext());
  debugPrint('_tinyWorkflowExample result: $result');
}
