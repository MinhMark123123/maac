import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

/// A `WorkflowListener` observes a run's lifecycle from the outside — step
/// start/success/failure, rollback, and every `context.write()` via
/// `onContextWrite` — without any step needing to log anything itself. This
/// is how telemetry/analytics/global loading indicators stay out of step
/// bodies.
class LoggingListener extends WorkflowListener<FlowContext> {
  final void Function(String message) log;
  LoggingListener(this.log);

  @override
  void onWorkflowStart(FlowContext context) => log('[listener] onWorkflowStart');

  @override
  void onStepStart(String stepId, FlowContext context) => log('[listener] onStepStart: $stepId');

  @override
  void onStepSuccess(String stepId, FlowContext context) => log('[listener] onStepSuccess: $stepId');

  @override
  void onContextWrite(String key, Object? value, String? writerStepId, FlowContext context) =>
      log('[listener] onContextWrite: "$key" = $value (written by "$writerStepId")');

  @override
  void onWorkflowSuccess(FlowContext context) => log('[listener] onWorkflowSuccess');
}

class ListenerBasicExamplePage extends StatelessWidget {
  const ListenerBasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'WorkflowListener: Observing a Run',
      description:
          'Two plain steps that do no logging themselves. A WorkflowListener attached to the runner '
          'observes every lifecycle event — including onContextWrite, fired whenever a step writes to '
          'FlowContext — purely from the outside.',
      onRun: (log) async {
        final flowContext = FlowContext();

        final greetStep = WorkflowStep<FlowContext>.action(
          id: 'build_greeting',
          execute: (ctx, token) {
            ctx.write('greeting', 'Hello, workflow!');
            return const StepSuccess();
          },
        );

        final noopStep = WorkflowStep<FlowContext>.action(id: 'noop', execute: (ctx, token) => const StepSuccess());

        final runner = WorkflowRunner<FlowContext>(steps: [greetStep, noopStep], listener: LoggingListener(log));

        await runner.run(flowContext);
      },
    );
  }
}
