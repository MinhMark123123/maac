import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// (category, label, description, route) for every registered "Basics"
/// example — one screen per package concept, deliberately minimal (see
/// `BasicExamplePage`), as opposed to the fuller showcase flows on the
/// dashboard.
const basicsExampleDefinitions = [
  ('Core', 'FlowContext: Scoped Immutability', 'Writes are locked to the step that made them.', '/basics/flow-context'),
  (
    'Core',
    'WorkflowRunner: Sequential Run & Rollback',
    'Steps run in order; a failure rolls back completed ones (LIFO).',
    '/basics/basic-run',
  ),
  ('Core', 'CancellationToken: Cancelling Mid-Flight', 'Cooperative cancellation between units of work.', '/basics/cancellation'),
  ('Core', 'WorkflowListener: Observing a Run', 'Lifecycle + context-write events, observed from the outside.', '/basics/listener'),
  (
    'Step Definitions',
    'WorkflowStep.action: Functional Steps',
    'A subclass and a .action() step, side by side.',
    '/basics/action-step',
  ),
  (
    'Step Definitions',
    'WorkflowStep.sustained: No Natural Completion',
    'A step that runs until cancelled — a live subscription.',
    '/basics/sustained-step',
  ),
  (
    'Step Definitions',
    'InteractiveStep: Pausing for Input',
    'Pauses at onActivate, resumes via WorkflowRunner.submit.',
    '/basics/interactive-step',
  ),
  ('Composites & Decorators', 'ConditionalStep: Branching', 'Runs a step only if a predicate over the context is true.', '/basics/conditional-step'),
  (
    'Composites & Decorators',
    'WorkflowStepGroup: Sub-Pipelines',
    'Embeds a whole sub-pipeline as a single step.',
    '/basics/workflow-step-group',
  ),
  (
    'Composites & Decorators',
    'ParallelStepGroup: Concurrent Sub-Steps',
    'Runs sub-steps concurrently as a single step.',
    '/basics/parallel-step-group',
  ),
  ('Composites & Decorators', 'RetryStepDecorator: Auto-Retry', 'Retries a brittle step with backoff.', '/basics/retry-decorator'),
  (
    'Composites & Decorators',
    'TimeoutStepDecorator: Bounding Duration',
    'Fails a step that runs too long, without cancelling the run.',
    '/basics/timeout-decorator',
  ),
  ('Progress', 'WorkflowRunner.progress: Live Step Status', 'Current step + status of every step, updated live.', '/basics/progress'),
  (
    'Concurrency',
    'ManagedWorkflowRunner: ConcurrencyStrategy',
    'ignore / cancelExisting / enqueue — one logical run at a time.',
    '/basics/managed-workflow-runner',
  ),
  (
    'Concurrency',
    'ParallelWorkflowRunner: Independent Runs',
    'N fully independent concurrent runs, none superseding another.',
    '/basics/parallel-workflow-runner',
  ),
  (
    'Concurrency',
    'SharedWorkflowRunner: JoinCompletionRule',
    'waitAll / overrideByLatest / firstWins — multiple callers, one run.',
    '/basics/shared-workflow-runner',
  ),
];

class BasicsPage extends StatelessWidget {
  const BasicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <String>[];
    for (final (category, _, _, _) in basicsExampleDefinitions) {
      if (!categories.contains(category)) categories.add(category);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Basics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final category in categories) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(category, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            for (final entry in basicsExampleDefinitions.where((e) => e.$1 == category))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    title: Text(entry.$2),
                    subtitle: Text(entry.$3),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go(entry.$4),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
