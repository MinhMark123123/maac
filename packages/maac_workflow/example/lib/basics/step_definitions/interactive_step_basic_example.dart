import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

/// Pauses at `onActivate` and waits for `WorkflowRunner.submit` — no
/// `Completer` hand-rolled by the step author, the engine owns that.
class _ConfirmStep extends InteractiveStep<FlowContext, String> {
  final void Function(String message) log;
  _ConfirmStep(this.log);

  @override
  String get id => 'confirm';

  @override
  void onActivate(FlowContext context, CancellationToken token) {
    log('confirm: activated — paused, waiting for external submit()...');
  }

  @override
  StepResult onSubmit(FlowContext context, String input, CancellationToken token) {
    log('confirm: onSubmit received input = "$input"');
    return const StepSuccess();
  }
}

class InteractiveStepBasicExamplePage extends StatelessWidget {
  const InteractiveStepBasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'InteractiveStep: Pausing for External Input',
      description:
          'An InteractiveStep pauses the run at onActivate and waits. This example simulates a user '
          'confirming a dialog 600ms later by calling WorkflowRunner.submit() from outside the run() call '
          '— in a real app that\'d be a button\'s onPressed handler instead.',
      runLabel: 'Start (auto-confirms after 600ms)',
      onRun: (log) async {
        final flowContext = FlowContext();
        final confirmStep = _ConfirmStep(log);
        final runner = WorkflowRunner<FlowContext>(steps: [confirmStep]);

        final resultFuture = runner.run(flowContext);

        unawaited(
          Future<void>.delayed(const Duration(milliseconds: 600), () {
            log('--- Simulating a user tapping "Confirm" ---');
            runner.submit('confirm', 'user_confirmed');
          }),
        );

        final result = await resultFuture;
        switch (result) {
          case WorkflowSuccess():
            log('Resumed and finished successfully after submit().');
          case WorkflowFailure(:final error):
            log('Failed: $error');
          case WorkflowCancelled():
            log('Cancelled.');
        }
      },
    );
  }
}
