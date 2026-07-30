import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

/// A plain `WorkflowStep` subclass — for comparison against `.action()`
/// below. Reach for a subclass when a step needs its own persistent
/// fields/dependencies; `.action()` otherwise.
class _GreetSubclassStep extends WorkflowStep<FlowContext> {
  final void Function(String message) log;
  _GreetSubclassStep(this.log);

  @override
  String get id => 'greet_subclass';

  @override
  Future<StepResult> execute(FlowContext context, CancellationToken token) async {
    log('greet_subclass: executing (defined via a WorkflowStep subclass)');
    return const StepSuccess();
  }
}

class ActionStepBasicExamplePage extends StatelessWidget {
  const ActionStepBasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'WorkflowStep.action: Functional Step Definition',
      description:
          'Two functionally identical steps, back to back: one defined as a WorkflowStep subclass, one '
          'via the WorkflowStep.action(...) factory. Same behavior — action() just skips the class '
          'declaration for steps that don\'t need their own fields.',
      onRun: (log) async {
        final flowContext = FlowContext();

        final subclassStep = _GreetSubclassStep(log);

        final actionStep = WorkflowStep<FlowContext>.action(
          id: 'greet_action',
          execute: (ctx, token) {
            log('greet_action: executing (defined via WorkflowStep.action)');
            return const StepSuccess();
          },
        );

        final runner = WorkflowRunner<FlowContext>(steps: [subclassStep, actionStep]);
        final result = await runner.run(flowContext);

        switch (result) {
          case WorkflowSuccess():
            log('Both steps succeeded — identical outcome, different definition style.');
          case WorkflowFailure(:final error):
            log('Failed: $error');
          case WorkflowCancelled():
            log('Cancelled.');
        }
      },
    );
  }
}
