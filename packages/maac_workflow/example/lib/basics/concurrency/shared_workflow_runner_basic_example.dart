import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

/// `SharedWorkflowRunner` merges multiple callers into one shared physical
/// run. `JoinCompletionRule` governs when the UI-facing `isSessionActive`
/// signal closes — and, for two of the three rules, whether closing it also
/// cancels the still-in-flight run for every joiner still attached.
class SharedWorkflowRunnerBasicExamplePage extends StatefulWidget {
  const SharedWorkflowRunnerBasicExamplePage({super.key});

  @override
  State<SharedWorkflowRunnerBasicExamplePage> createState() => _SharedWorkflowRunnerBasicExamplePageState();
}

class _SharedWorkflowRunnerBasicExamplePageState extends State<SharedWorkflowRunnerBasicExamplePage> {
  JoinCompletionRule _rule = JoinCompletionRule.waitAll;

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'SharedWorkflowRunner: JoinCompletionRule',
      description:
          'Two joiners attach to the same shared 800ms run. Joiner A leaves after 200ms, joiner B leaves '
          'after 400ms. Pick a rule and re-run to see when isSessionActive closes — and, under '
          'overrideByLatest/firstWins, watch a joiner\'s result flip to WorkflowCancelled even though '
          'nothing "failed".',
      controls: DropdownButton<JoinCompletionRule>(
        value: _rule,
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: JoinCompletionRule.waitAll, child: Text('waitAll — closes once every joiner has left')),
          DropdownMenuItem(value: JoinCompletionRule.overrideByLatest, child: Text('overrideByLatest — closes when the latest joiner leaves')),
          DropdownMenuItem(value: JoinCompletionRule.firstWins, child: Text('firstWins — closes on the very first leave()')),
        ],
        onChanged: (value) => setState(() => _rule = value!),
      ),
      runLabel: 'Join with 2 callers',
      onRun: (log) async {
        final shared = SharedWorkflowRunner<FlowContext>(
          createRunner: () => WorkflowRunner<FlowContext>(
            steps: [
              WorkflowStep<FlowContext>.action(
                id: 'work',
                execute: (ctx, token) async {
                  await Future<void>.delayed(const Duration(milliseconds: 800));
                  return const StepSuccess();
                },
              ),
            ],
          ),
          rule: _rule,
        );

        final joinerA = shared.join(FlowContext());
        log('Joiner A joined. isSessionActive: ${shared.isSessionActive.value}');
        final joinerB = shared.join(FlowContext());
        log('Joiner B joined (same session — no second physical run started).');

        unawaited(joinerA.result.then((r) => log('Joiner A result: ${r.runtimeType}')));
        unawaited(joinerB.result.then((r) => log('Joiner B result: ${r.runtimeType}')));

        await Future<void>.delayed(const Duration(milliseconds: 200));
        log('--- Joiner A leaves ---');
        joinerA.leave();
        log('isSessionActive after A leaves: ${shared.isSessionActive.value}');

        await Future<void>.delayed(const Duration(milliseconds: 200));
        log('--- Joiner B leaves ---');
        joinerB.leave();
        log('isSessionActive after B leaves: ${shared.isSessionActive.value}');

        await Future.wait([joinerA.result, joinerB.result]);
        log('Both results settled.');
      },
    );
  }
}
