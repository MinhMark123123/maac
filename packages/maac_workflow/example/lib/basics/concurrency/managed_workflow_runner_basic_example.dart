import 'package:flutter/material.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../widgets/basic_example_page.dart';

/// `ManagedWorkflowRunner` governs what happens when `run()` is called again
/// while a previous call is still in flight — exactly one logical run "owns"
/// the runner at a time, under one of three strategies.
class ManagedWorkflowRunnerBasicExamplePage extends StatefulWidget {
  const ManagedWorkflowRunnerBasicExamplePage({super.key});

  @override
  State<ManagedWorkflowRunnerBasicExamplePage> createState() => _ManagedWorkflowRunnerBasicExamplePageState();
}

class _ManagedWorkflowRunnerBasicExamplePageState extends State<ManagedWorkflowRunnerBasicExamplePage> {
  ConcurrencyStrategy _strategy = const ConcurrencyStrategy.cancelExisting();

  @override
  Widget build(BuildContext context) {
    return BasicExamplePage(
      title: 'ManagedWorkflowRunner: ConcurrencyStrategy',
      description:
          'Fires 3 rapid run() calls, 100ms apart, against a ManagedWorkflowRunner wrapping a single 400ms '
          'step — under the strategy picked below. Re-run with each strategy to see how overlapping calls '
          'are handled differently.',
      controls: DropdownButton<ConcurrencyStrategy>(
        value: _strategy,
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: ConcurrencyStrategy.ignore(), child: Text('ignore — swallow calls while one is in flight')),
          DropdownMenuItem(value: ConcurrencyStrategy.cancelExisting(), child: Text('cancelExisting — cancel the old one, start the new one')),
          DropdownMenuItem(value: ConcurrencyStrategy.enqueue(), child: Text('enqueue — run strictly one after another')),
        ],
        onChanged: (value) => setState(() => _strategy = value!),
      ),
      runLabel: 'Fire 3 rapid calls',
      onRun: (log) async {
        final managed = ManagedWorkflowRunner<FlowContext>(
          createRunner: () => WorkflowRunner<FlowContext>(
            steps: [
              WorkflowStep<FlowContext>.action(
                id: 'work',
                execute: (ctx, token) async {
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                  return const StepSuccess();
                },
              ),
            ],
          ),
          strategy: _strategy,
        );

        final futures = <Future<WorkflowResult<FlowContext>>>[];
        for (var i = 1; i <= 3; i++) {
          log('Call #$i: run()');
          futures.add(managed.run(FlowContext()));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }

        final results = await Future.wait(futures);
        for (var i = 0; i < results.length; i++) {
          log('Call #${i + 1} resolved: ${results[i].runtimeType}');
        }
      },
    );
  }
}
