import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

class TimeoutDecoratorBasicExamplePage extends StatelessWidget {
  const TimeoutDecoratorBasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'TimeoutStepDecorator: Failing a Step That Runs Too Long',
      description:
          'Wraps a step that takes 2s with a 500ms timeout — TimeoutStepDecorator fails it with a '
          'TimeoutException as a regular StepFailure, without cancelling the whole workflow (a timeout is '
          'retryable/rollback-able, unlike WorkflowCancelled).',
      onRun: (log) async {
        final flowContext = FlowContext();

        final slowStep = WorkflowStep<FlowContext>.action(
          id: 'fetch_large_report',
          execute: (ctx, token) async {
            log('fetch_large_report: starting a 2s operation...');
            await Future<void>.delayed(const Duration(seconds: 2));
            log('fetch_large_report: finished (should not print — timeout fires first).');
            return const StepSuccess();
          },
        );

        final withTimeout = TimeoutStepDecorator<FlowContext>(step: slowStep, timeout: const Duration(milliseconds: 500));

        final runner = WorkflowRunner<FlowContext>(steps: [withTimeout]);
        final result = await runner.run(flowContext);

        switch (result) {
          case WorkflowSuccess():
            log('Unexpected success.');
          case WorkflowFailure(:final error):
            log('Failed as expected: $error');
          case WorkflowCancelled():
            log('Cancelled.');
        }
      },
    );
  }
}
