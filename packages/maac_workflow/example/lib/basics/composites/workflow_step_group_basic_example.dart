import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

class WorkflowStepGroupBasicExamplePage extends StatelessWidget {
  const WorkflowStepGroupBasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'WorkflowStepGroup: Embedding a Sub-Pipeline',
      description:
          'Wraps 2 sub-steps as one named step ("checkout") inside a 2-step parent workflow. The parent '
          'only ever sees "checkout" succeed or fail as a single unit — its inner steps run through their '
          'own nested WorkflowRunner.',
      onRun: (log) async {
        final flowContext = FlowContext();

        final reserveInventory = WorkflowStep<FlowContext>.action(
          id: 'reserve_inventory',
          execute: (ctx, token) {
            log('  [inside group] reserve_inventory: executing');
            return const StepSuccess();
          },
        );
        final chargeCard = WorkflowStep<FlowContext>.action(
          id: 'charge_card',
          execute: (ctx, token) {
            log('  [inside group] charge_card: executing');
            return const StepSuccess();
          },
        );

        final checkoutGroup = WorkflowStepGroup<FlowContext>(id: 'checkout', steps: [reserveInventory, chargeCard]);

        final sendReceipt = WorkflowStep<FlowContext>.action(
          id: 'send_receipt',
          execute: (ctx, token) {
            log('send_receipt: executing (parent-level step, after the group)');
            return const StepSuccess();
          },
        );

        final runner = WorkflowRunner<FlowContext>(steps: [checkoutGroup, sendReceipt]);
        final result = await runner.run(flowContext);

        switch (result) {
          case WorkflowSuccess():
            log('Workflow succeeded — the parent only ever tracked "checkout" as one step.');
          case WorkflowFailure(:final failedStepId, :final error):
            log('Failed at "$failedStepId": $error');
          case WorkflowCancelled():
            log('Cancelled.');
        }
      },
    );
  }
}
