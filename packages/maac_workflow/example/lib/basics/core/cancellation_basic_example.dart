import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

/// A `CancellationToken` is cooperative: a step checks `token.throwIfCancelled()`
/// between units of work, so `cancel()` stops it *between* chunks instead of
/// interrupting it mid-instruction. The whole run then resolves as
/// `WorkflowCancelled` instead of `WorkflowSuccess`/`WorkflowFailure`.
class CancellationBasicExamplePage extends StatelessWidget {
  const CancellationBasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'CancellationToken: Cancelling Mid-Flight',
      description:
          'A step "downloads" 5 chunks, 400ms apart, checking the CancellationToken between each one. '
          'This example cancels it after ~2 chunks — watch the download stop instead of running to '
          'completion, and the run resolve as WorkflowCancelled.',
      onRun: (log) async {
        final flowContext = FlowContext();
        final token = CancellationToken();

        final downloadStep = WorkflowStep<FlowContext>.action(
          id: 'download_file',
          execute: (ctx, stepToken) async {
            for (var chunk = 1; chunk <= 5; chunk++) {
              await Future<void>.delayed(const Duration(milliseconds: 400));
              stepToken.throwIfCancelled();
              log('Downloaded chunk $chunk/5');
            }
            return const StepSuccess();
          },
        );

        final runner = WorkflowRunner<FlowContext>(steps: [downloadStep]);
        final resultFuture = runner.run(flowContext, cancellationToken: token);

        unawaited(
          Future<void>.delayed(const Duration(milliseconds: 900), () {
            log('--- Cancelling after ~2 chunks ---');
            token.cancel();
          }),
        );

        final result = await resultFuture;
        switch (result) {
          case WorkflowSuccess():
            log('Finished — cancel() fired too late to interrupt it.');
          case WorkflowFailure(:final error):
            log('Failed: $error');
          case WorkflowCancelled():
            log('Cancelled as expected — the download stopped partway through.');
        }
      },
    );
  }
}
