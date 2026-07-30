import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

/// `WorkflowStep.sustained` models work with no natural completion of its
/// own — a live subscription, an open connection — that runs until the step
/// is cancelled or deactivated.
class SustainedStepBasicExamplePage extends StatelessWidget {
  const SustainedStepBasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'WorkflowStep.sustained: Work With No Natural Completion',
      description:
          'Models a live "ticker" subscription. start() opens it, stop() tears it down — execute() only '
          'resolves once the step is cancelled, not when start() returns. This example cancels it after '
          '~2 ticks.',
      runLabel: 'Start watching ticks',
      onRun: (log) async {
        final flowContext = FlowContext();
        final token = CancellationToken();
        StreamSubscription<int>? subscription;

        final watchTicksStep = WorkflowStep<FlowContext>.sustained(
          id: 'watch_ticks',
          start: (ctx, fail) {
            subscription = Stream.periodic(const Duration(milliseconds: 400), (i) => i + 1).listen((tick) {
              log('Tick #$tick');
            });
          },
          stop: (ctx) {
            log('stop(): subscription cancelled.');
            subscription?.cancel();
          },
        );

        final runner = WorkflowRunner<FlowContext>(steps: [watchTicksStep]);
        final resultFuture = runner.run(flowContext, cancellationToken: token);

        unawaited(
          Future<void>.delayed(const Duration(milliseconds: 900), () {
            log('--- Cancelling after ~2 ticks ---');
            token.cancel();
          }),
        );

        final result = await resultFuture;
        switch (result) {
          case WorkflowSuccess():
            log('Unexpected — sustained steps only resolve via cancellation.');
          case WorkflowFailure(:final error):
            log('Failed: $error');
          case WorkflowCancelled():
            log('Cancelled as expected — ticking stopped.');
        }
      },
    );
  }
}
