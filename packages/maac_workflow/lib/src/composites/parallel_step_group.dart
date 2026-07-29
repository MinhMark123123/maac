import '../cancellation_token.dart';
import '../flow_context.dart';
import '../result.dart';
import '../runner.dart';
import '../step.dart';

/// Runs [subSteps] concurrently as a single [WorkflowStep] — the concurrent
/// counterpart to [WorkflowStepGroup]'s sequential composition. Succeeds
/// only if every sub-step succeeds or is skipped; fails with the first
/// failure encountered (the others are still awaited to completion, per
/// `Future.wait`'s default behavior, before this step resolves).
///
/// [listener], if given, is fired with each sub-step's own lifecycle events
/// (`onStepStart`/`onStepSuccess`/`onStepFailure`/`onStepSkip` and the
/// rollback trio) as they happen — the *parent* [WorkflowRunner]/its own
/// `listener` only ever sees this group's single [id], so this is how a
/// step tracker UI can still show live status for each parallel branch.
///
/// Known limitation: unlike [WorkflowStepGroup] (which runs its sub-steps
/// through a nested [WorkflowRunner], giving each one its own turn as
/// [FlowContext]'s active step), sub-steps here execute genuinely
/// concurrently against the *same* [FlowContext] active-step slot — a
/// single field, not one per branch. Every write any sub-step makes while
/// this group is executing is attributed to this group's own [id], not to
/// the individual sub-step that made it, so two sub-steps racing to write
/// the *same* key are not mutually protected by scoped immutability the way
/// two sequential steps would be. Give concurrent sub-steps disjoint keys.
class ParallelStepGroup<TContext extends FlowContext> extends WorkflowStep<TContext> {
  @override
  final String id;
  @override
  final String description;
  final List<WorkflowStep<TContext>> subSteps;
  final WorkflowListener<TContext>? listener;

  ParallelStepGroup({
    required this.id,
    required this.subSteps,
    this.description = '',
    this.listener,
  });

  @override
  Future<StepResult> execute(TContext context, CancellationToken token) async {
    try {
      final results = await Future.wait(subSteps.map((s) => _runSubStep(s, context, token)));

      for (final res in results) {
        if (res is StepFailure) {
          return StepFailure(res.error, res.stackTrace);
        }
      }
      return const StepSuccess();
    } catch (e, stack) {
      return StepFailure(e, stack);
    }
  }

  Future<StepResult> _runSubStep(WorkflowStep<TContext> step, TContext context, CancellationToken token) async {
    final canRun = await step.canRun(context);
    if (!canRun) {
      listener?.onStepSkip(step.id, context);
      return const StepSkipped();
    }

    listener?.onStepStart(step.id, context);
    final result = await step.execute(context, token);
    switch (result) {
      case StepSuccess():
        listener?.onStepSuccess(step.id, context);
      case StepFailure(:final error, :final stackTrace):
        listener?.onStepFailure(step.id, error, stackTrace, context);
      case StepSkipped():
        listener?.onStepSkip(step.id, context);
    }
    return result;
  }

  @override
  Future<void> rollback(TContext context) async {
    await Future.wait(subSteps.map((s) => _rollbackSubStep(s, context)));
  }

  Future<void> _rollbackSubStep(WorkflowStep<TContext> step, TContext context) async {
    try {
      listener?.onStepRollbackStart(step.id, context);
      await step.rollback(context);
      listener?.onStepRollbackSuccess(step.id, context);
    } catch (e) {
      listener?.onStepRollbackFailure(step.id, e, context);
      rethrow;
    }
  }

  @override
  Future<void> onDeactivateOrCancel(TContext context) async {
    await Future.wait(subSteps.map((s) => s.onDeactivateOrCancel(context)));
  }
}
