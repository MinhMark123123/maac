import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

class ProgressBasicExamplePage extends StatelessWidget {
  const ProgressBasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'WorkflowRunner.progress: Live Step Status',
      description:
          'progress is a ValueListenable<WorkflowProgress> — the current step id and the last known '
          'status of every step, updated live as the run proceeds. This example listens to it directly '
          '(no WorkflowListener needed) and logs every change.',
      onRun: (log) async {
        final flowContext = FlowContext();

        final stepA = WorkflowStep<FlowContext>.action(
          id: 'step_a',
          execute: (ctx, token) async {
            await Future<void>.delayed(const Duration(milliseconds: 300));
            return const StepSuccess();
          },
        );
        final stepB = WorkflowStep<FlowContext>.action(
          id: 'step_b',
          execute: (ctx, token) async {
            await Future<void>.delayed(const Duration(milliseconds: 300));
            return const StepSuccess();
          },
        );

        final runner = WorkflowRunner<FlowContext>(steps: [stepA, stepB]);

        void reportProgress() {
          final progress = runner.progress.value;
          log('progress: current="${progress.currentStepId}", statuses=${progress.stepStatuses}');
        }

        runner.progress.addListener(reportProgress);
        await runner.run(flowContext);
        runner.progress.removeListener(reportProgress);
        runner.dispose();

        log('Done — listener detached and runner disposed.');
      },
    );
  }
}
