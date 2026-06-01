import 'cancellation_token.dart';
import 'result.dart';
import 'step.dart';

/// Listener interface for workflow lifecycle events, useful for global loading spinners, analytics, and metrics.
abstract class WorkflowListener<TContext> {
  void onWorkflowStart(TContext context) {}
  void onStepStart(String stepId, TContext context) {}
  void onStepSuccess(String stepId, TContext context) {}
  void onStepSkip(String stepId, TContext context) {}
  void onStepFailure(String stepId, Object error, StackTrace stackTrace, TContext context) {}
  
  void onStepRollbackStart(String stepId, TContext context) {}
  void onStepRollbackSuccess(String stepId, TContext context) {}
  void onStepRollbackFailure(String stepId, Object error, TContext context) {}
  
  void onWorkflowSuccess(TContext context) {}
  void onWorkflowFailure(Object error, StackTrace stackTrace, TContext context) {}
}

class StepExecutionException implements Exception {
  final WorkflowStep step;
  final Object error;
  final StackTrace stackTrace;

  StepExecutionException({required this.step, required this.error, required this.stackTrace});
}

class WorkflowRunner<TContext> {
  final List<WorkflowStep<TContext>> steps;
  final WorkflowListener<TContext>? listener;

  WorkflowRunner({required this.steps, this.listener});

  Future<WorkflowResult<TContext>> run(
    TContext context, {
    CancellationToken? cancellationToken,
  }) async {
    final token = cancellationToken ?? CancellationToken();
    final completedSteps = <WorkflowStep<TContext>>[];
    final stepHistory = <WorkflowStepEvent>[];

    listener?.onWorkflowStart(context);

    try {
      for (final step in steps) {
        token.throwIfCancelled();

        // 1. Evaluate if the step should execute
        final canExecute = await step.canRun(context);
        if (!canExecute) {
          stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.skipped));
          listener?.onStepSkip(step.id, context);
          continue;
        }

        // 2. Trigger step start lifecycle events
        listener?.onStepStart(step.id, context);
        stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.running));

        // 3. Execute core step logic
        final result = await step.execute(context, token);
        token.throwIfCancelled();

        // 4. Analyze execution result
        switch (result) {
          case StepSuccess():
            completedSteps.add(step);
            stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.success));
            listener?.onStepSuccess(step.id, context);
            
          case StepFailure(:final error, :final stackTrace):
            stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.failed, error: error));
            listener?.onStepFailure(step.id, error, stackTrace, context);
            throw StepExecutionException(step: step, error: error, stackTrace: stackTrace);
            
          case StepSkipped():
            stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.skipped));
            listener?.onStepSkip(step.id, context);
        }
      }

      listener?.onWorkflowSuccess(context);
      return WorkflowSuccess(context: context, history: stepHistory);

    } catch (e, stack) {
      listener?.onWorkflowFailure(e, stack, context);

      // Trigger compensation (rollback) phase in reverse (LIFO) order for completed steps
      final rollbackErrors = <String, Object>{};
      for (final step in completedSteps.reversed) {
        try {
          listener?.onStepRollbackStart(step.id, context);
          stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.running)); // Log rollback state
          await step.rollback(context);
          stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.rollbackSuccess));
          listener?.onStepRollbackSuccess(step.id, context);
        } catch (rollbackErr) {
          rollbackErrors[step.id] = rollbackErr;
          stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.rollbackFailed, error: rollbackErr));
          listener?.onStepRollbackFailure(step.id, rollbackErr, context);
        }
      }

      if (e is WorkflowCancelledException || token.isCancelled) {
        return WorkflowCancelled(context: context, history: stepHistory);
      }

      return WorkflowFailure(
        context: context,
        failedStepId: e is StepExecutionException ? e.step.id : 'unknown',
        error: e is StepExecutionException ? e.error : e,
        stackTrace: stack,
        rollbackErrors: rollbackErrors,
        history: stepHistory,
      );
    }
  }
}
