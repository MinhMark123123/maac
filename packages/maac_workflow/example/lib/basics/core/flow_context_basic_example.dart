import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

/// `FlowContext` is a plain key-value store shared across every step of a
/// workflow. It doesn't need subclassing for a case this simple — `read`/
/// `write` work directly against a bare `FlowContext()`.
class FlowContextBasicExamplePage extends StatelessWidget {
  const FlowContextBasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'FlowContext: Scoped Immutability',
      description:
          'FlowContext.write() enforces "scoped immutability": once a key is written by a step, only '
          'that same step may write it again — every other step gets read-only access. Step 1 writes '
          '"user_id". Step 2 reads it (reads are always unrestricted). Step 3 then tries to overwrite '
          'it — watch the engine reject it.',
      onRun: (log) async {
        final flowContext = FlowContext();

        final writeUserId = WorkflowStep<FlowContext>.action(
          id: 'write_user_id',
          execute: (ctx, token) {
            ctx.write('user_id', 42);
            log('Step 1 (write_user_id): wrote user_id = 42');
            return const StepSuccess();
          },
        );

        final readUserId = WorkflowStep<FlowContext>.action(
          id: 'read_user_id',
          execute: (ctx, token) {
            final userId = ctx.read<int>('user_id');
            log('Step 2 (read_user_id): read user_id = $userId');
            return const StepSuccess();
          },
        );

        final overwriteUserId = WorkflowStep<FlowContext>.action(
          id: 'overwrite_user_id',
          execute: (ctx, token) {
            log('Step 3 (overwrite_user_id): attempting to overwrite user_id...');
            ctx.write('user_id', 999); // throws — user_id already belongs to step 1
            return const StepSuccess();
          },
        );

        final runner = WorkflowRunner<FlowContext>(steps: [writeUserId, readUserId, overwriteUserId]);
        final result = await runner.run(flowContext);

        switch (result) {
          case WorkflowSuccess():
            log('Unexpected success — scoped immutability should have rejected step 3.');
          case WorkflowFailure(:final error):
            log('Workflow failed as expected: $error');
          case WorkflowCancelled():
            log('Cancelled.');
        }
      },
    );
  }
}
