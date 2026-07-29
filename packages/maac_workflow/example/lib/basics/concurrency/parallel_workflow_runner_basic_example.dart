import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

/// Context for the parallel demo — carries [index] so each of the 3
/// concurrent runs can simulate a different amount of work, proving they
/// really do run independently rather than superseding one another (unlike
/// `ManagedWorkflowRunner.cancelExisting`).
class _WorkContext extends FlowContext {
  final int index;
  _WorkContext(this.index);
}

/// `ParallelWorkflowRunner` starts N fully independent runs — each gets its
/// own isolated `WorkflowRunner` + `FlowContext` instance via the factory,
/// none of them cancel or wait on each other.
class ParallelWorkflowRunnerBasicExamplePage extends StatelessWidget {
  const ParallelWorkflowRunnerBasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'ParallelWorkflowRunner: Independent Concurrent Runs',
      description:
          'Starts 3 independent runs at once, taking 200ms/400ms/600ms respectively. Watch them finish in '
          'that same real-time order, and activeRuns shrink as each one settles — none of them cancel or '
          'wait on the others.',
      runLabel: 'Start 3 parallel runs',
      onRun: (log) async {
        final parallel = ParallelWorkflowRunner<_WorkContext>(
          createRunner: () => WorkflowRunner<_WorkContext>(
            steps: [
              WorkflowStep<_WorkContext>.action(
                id: 'work',
                execute: (ctx, token) async {
                  await Future<void>.delayed(Duration(milliseconds: 200 * ctx.index));
                  return const StepSuccess();
                },
              ),
            ],
          ),
        );

        final handles = [for (var i = 1; i <= 3; i++) parallel.run(_WorkContext(i))];
        log('Started ${handles.length} independent runs. activeRuns: ${parallel.activeRuns.length}');

        for (final handle in handles) {
          unawaited(
            handle.result.then((result) {
              log('Run #${handle.context.index} finished: ${result.runtimeType} (activeRuns now: ${parallel.activeRuns.length})');
            }),
          );
        }

        await Future.wait(handles.map((h) => h.result));
        log('All 3 runs settled.');
      },
    );
  }
}
