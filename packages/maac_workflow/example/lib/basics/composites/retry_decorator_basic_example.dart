import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

class RetryDecoratorBasicExamplePage extends StatelessWidget {
  const RetryDecoratorBasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'RetryStepDecorator: Auto-Retry with Backoff',
      description:
          'Wraps a flaky step that fails its first 2 attempts, then succeeds on the 3rd — RetryStepDecorator '
          'retries automatically with a short exponential backoff, no hand-written retry loop.',
      onRun: (log) async {
        final flowContext = FlowContext();
        var attempt = 0;

        final flakyStep = WorkflowStep<FlowContext>.action(
          id: 'sync_data',
          execute: (ctx, token) {
            attempt++;
            log('sync_data: attempt #$attempt');
            if (attempt < 3) return StepFailure(Exception('transient network error'));
            return const StepSuccess();
          },
        );

        final retryable = RetryStepDecorator<FlowContext>(
          step: flakyStep,
          maxAttempts: 3,
          initialDelay: const Duration(milliseconds: 200),
          backoffFactor: 1.5,
        );

        final runner = WorkflowRunner<FlowContext>(steps: [retryable]);
        final result = await runner.run(flowContext);

        switch (result) {
          case WorkflowSuccess():
            log('Succeeded after $attempt attempts, retried automatically.');
          case WorkflowFailure(:final error):
            log('Failed after $attempt attempts: $error');
          case WorkflowCancelled():
            log('Cancelled.');
        }
      },
    );
  }
}
