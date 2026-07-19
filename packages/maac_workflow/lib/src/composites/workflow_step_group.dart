import '../cancellation_token.dart';
import '../result.dart';
import '../runner.dart';
import '../step.dart';

/// Lets a whole sub-pipeline of [steps] be embedded as a single [WorkflowStep]
/// inside a parent [WorkflowRunner], so large flows can be composed out of named,
/// independently testable sub-flows instead of one flat list of steps.
///
/// Internally runs [steps] through its own [WorkflowRunner]. If one of them fails,
/// that sub-workflow already rolls back its own completed steps before the failure
/// reaches the parent, so the parent only needs to know the group failed. If the
/// group as a whole succeeds but a later, sibling step in the *parent* workflow
/// fails, the parent calls [rollback] on this group like any other step — which
/// rolls back every sub-step in reverse (LIFO) order, relying on the same
/// convention as the rest of the package: a step's [WorkflowStep.rollback] must be
/// a safe no-op if that step never actually ran (see [ConditionalStep.rollback]).
class WorkflowStepGroup<TContext> extends WorkflowStep<TContext> {
  @override
  final String id;
  @override
  final String description;
  final List<WorkflowStep<TContext>> steps;
  final WorkflowListener<TContext>? listener;

  WorkflowStepGroup({
    required this.id,
    required this.steps,
    this.description = '',
    this.listener,
  });

  @override
  Future<StepResult<void>> execute(TContext context, CancellationToken token) async {
    final runner = WorkflowRunner<TContext>(steps: steps, listener: listener);
    final result = await runner.run(context, cancellationToken: token);

    switch (result) {
      case WorkflowSuccess():
        return const StepSuccess(null);
      case WorkflowFailure(:final error, :final stackTrace):
        return StepFailure(error, stackTrace);
      case WorkflowCancelled():
        // The token driving the sub-workflow is the same one the parent passed
        // in, so it's already cancelled at this point. The parent's own
        // `token.throwIfCancelled()` check right after `execute()` returns will
        // short-circuit before this value is ever read.
        return StepFailure(WorkflowCancelledException(), StackTrace.current);
    }
  }

  @override
  Future<void> rollback(TContext context) async {
    for (final step in steps.reversed) {
      await step.rollback(context);
    }
  }
}
