import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

class ConditionalStepBasicExamplePage extends StatelessWidget {
  const ConditionalStepBasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'ConditionalStep: Branching on Context',
      description:
          'ConditionalStep wraps another step and only runs it if a predicate over the context is true — '
          'otherwise it\'s skipped, not failed. Below, "is_premium_user" is true, so the premium-email '
          'step runs and the trial-expired-email step is skipped.',
      onRun: (log) async {
        final flowContext = FlowContext()..write('is_premium_user', true);

        final sendPremiumEmail = ConditionalStep<FlowContext>(
          id: 'send_premium_email',
          condition: (ctx) => ctx.read<bool>('is_premium_user') ?? false,
          step: WorkflowStep<FlowContext>.action(
            id: 'send_premium_email_inner',
            execute: (ctx, token) {
              log('send_premium_email: condition was true — executing.');
              return const StepSuccess();
            },
          ),
        );

        final sendTrialExpiredEmail = ConditionalStep<FlowContext>(
          id: 'send_trial_expired_email',
          condition: (ctx) => !(ctx.read<bool>('is_premium_user') ?? false),
          step: WorkflowStep<FlowContext>.action(
            id: 'send_trial_expired_email_inner',
            execute: (ctx, token) {
              log('send_trial_expired_email: this should not print.');
              return const StepSuccess();
            },
          ),
        );

        final runner = WorkflowRunner<FlowContext>(steps: [sendPremiumEmail, sendTrialExpiredEmail]);
        final result = await runner.run(flowContext);

        for (final entry in runner.stepStatuses.entries) {
          log('Final status of "${entry.key}": ${entry.value}');
        }

        switch (result) {
          case WorkflowSuccess():
            log('Workflow succeeded — the skipped step did not fail the run.');
          case WorkflowFailure(:final error):
            log('Failed: $error');
          case WorkflowCancelled():
            log('Cancelled.');
        }
      },
    );
  }
}
