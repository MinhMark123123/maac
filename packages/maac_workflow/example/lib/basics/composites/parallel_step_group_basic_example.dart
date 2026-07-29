import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

/// Forwards each sub-step's own lifecycle events — the *parent*
/// WorkflowRunner only ever sees the group's single id, so this is how a UI
/// can still show live per-branch status.
class _SubStepLoggingListener extends WorkflowListener<FlowContext> {
  final void Function(String message) log;
  _SubStepLoggingListener(this.log);

  @override
  void onStepStart(String stepId, FlowContext context) => log('  [sub-step] $stepId: started');

  @override
  void onStepSuccess(String stepId, FlowContext context) => log('  [sub-step] $stepId: succeeded');
}

class ParallelStepGroupBasicExamplePage extends StatelessWidget {
  const ParallelStepGroupBasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'ParallelStepGroup: Concurrent Sub-Steps as One Step',
      description:
          'Runs 2 sub-steps (300ms and 500ms) concurrently as a single step — the parent workflow only '
          'sees "fetch_dashboard_data" succeed once both finish, not each sub-step individually.',
      onRun: (log) async {
        final flowContext = FlowContext();

        final fetchProfile = WorkflowStep<FlowContext>.action(
          id: 'fetch_profile',
          execute: (ctx, token) async {
            await Future<void>.delayed(const Duration(milliseconds: 300));
            return const StepSuccess();
          },
        );
        final fetchNotifications = WorkflowStep<FlowContext>.action(
          id: 'fetch_notifications',
          execute: (ctx, token) async {
            await Future<void>.delayed(const Duration(milliseconds: 500));
            return const StepSuccess();
          },
        );

        final parallelGroup = ParallelStepGroup<FlowContext>(
          id: 'fetch_dashboard_data',
          subSteps: [fetchProfile, fetchNotifications],
          listener: _SubStepLoggingListener(log),
        );

        final runner = WorkflowRunner<FlowContext>(steps: [parallelGroup]);
        final result = await runner.run(flowContext);

        switch (result) {
          case WorkflowSuccess():
            log('fetch_dashboard_data succeeded — both sub-steps finished.');
          case WorkflowFailure(:final error):
            log('Failed: $error');
          case WorkflowCancelled():
            log('Cancelled.');
        }
      },
    );
  }
}
