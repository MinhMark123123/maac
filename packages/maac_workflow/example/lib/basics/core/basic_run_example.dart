import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

/// The core value of the package: a `WorkflowRunner` runs `steps` in order,
/// and if one fails, every step that already succeeded gets `rollback`ed in
/// reverse (LIFO) order — automatically, without any hand-written
/// try/catch/undo bookkeeping.
class BasicRunExamplePage extends StatelessWidget {
  const BasicRunExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'WorkflowRunner: Sequential Run & Rollback',
      description:
          'Three steps: reserve a seat, charge a card, then send a confirmation email. The third step '
          'is made to fail — watch the first two steps get rolled back automatically, in reverse order.',
      onRun: (log) async {
        final flowContext = FlowContext();

        final reserveSeat = WorkflowStep<FlowContext>.action(
          id: 'reserve_seat',
          execute: (ctx, token) {
            log('reserve_seat: executing...');
            return const StepSuccess();
          },
          rollback: (ctx) async => log('reserve_seat: rolled back (seat released)'),
        );

        final chargeCard = WorkflowStep<FlowContext>.action(
          id: 'charge_card',
          execute: (ctx, token) {
            log('charge_card: executing...');
            return const StepSuccess();
          },
          rollback: (ctx) async => log('charge_card: rolled back (refunded)'),
        );

        final sendConfirmationEmail = WorkflowStep<FlowContext>.action(
          id: 'send_confirmation_email',
          execute: (ctx, token) {
            log('send_confirmation_email: executing... simulating an SMTP failure');
            return StepFailure(Exception('SMTP server unreachable'));
          },
        );

        final runner = WorkflowRunner<FlowContext>(steps: [reserveSeat, chargeCard, sendConfirmationEmail]);
        final result = await runner.run(flowContext);

        switch (result) {
          case WorkflowSuccess():
            log('All steps succeeded.');
          case WorkflowFailure(:final failedStepId, :final error):
            log('Failed at "$failedStepId": $error — rollback ran automatically (see above).');
          case WorkflowCancelled():
            log('Cancelled.');
        }
      },
    );
  }
}
