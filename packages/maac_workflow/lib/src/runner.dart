import 'package:flutter/foundation.dart';

import 'cancellation_token.dart';
import 'progress.dart';
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

  final ValueNotifier<WorkflowProgress> _progress = ValueNotifier(const WorkflowProgress());

  /// Live snapshot of which step is currently executing and the last known
  /// status of every step reached so far. Reset to all-[StepStatus.pending]
  /// at the start of every [run] call, so a [WorkflowRunner] reused across
  /// multiple runs always reflects the most recent one.
  ValueListenable<WorkflowProgress> get progress => _progress;

  WorkflowRunner({required this.steps, this.listener});

  void _markStep(String stepId, StepStatus status, {bool isCurrent = false}) {
    final statuses = Map<String, StepStatus>.from(_progress.value.stepStatuses)..[stepId] = status;
    _progress.value = _progress.value.copyWith(
      stepStatuses: statuses,
      currentStepId: isCurrent ? stepId : _progress.value.currentStepId,
    );
  }

  /// Releases the [progress] notifier. Call once the runner is no longer
  /// needed, e.g. from a ViewModel's `onDispose`.
  void dispose() => _progress.dispose();

  Future<WorkflowResult<TContext>> run(
    TContext context, {
    CancellationToken? cancellationToken,
  }) async {
    final token = cancellationToken ?? CancellationToken();
    final completedSteps = <WorkflowStep<TContext>>[];
    final stepHistory = <WorkflowStepEvent>[];

    _progress.value = WorkflowProgress(
      stepStatuses: {for (final step in steps) step.id: StepStatus.pending},
    );

    listener?.onWorkflowStart(context);

    try {
      for (final step in steps) {
        token.throwIfCancelled();

        // 1. Evaluate if the step should execute
        final canExecute = await step.canRun(context);
        if (!canExecute) {
          stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.skipped));
          _markStep(step.id, StepStatus.skipped);
          listener?.onStepSkip(step.id, context);
          continue;
        }

        // 2. Trigger step start lifecycle events
        listener?.onStepStart(step.id, context);
        stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.running));
        _markStep(step.id, StepStatus.running, isCurrent: true);

        // 3. Execute core step logic
        final result = await step.execute(context, token);
        token.throwIfCancelled();

        // 4. Analyze execution result
        switch (result) {
          case StepSuccess():
            completedSteps.add(step);
            stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.success));
            _markStep(step.id, StepStatus.success);
            listener?.onStepSuccess(step.id, context);

          case StepFailure(:final error, :final stackTrace):
            stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.failed, error: error));
            _markStep(step.id, StepStatus.failed);
            listener?.onStepFailure(step.id, error, stackTrace, context);
            throw StepExecutionException(step: step, error: error, stackTrace: stackTrace);

          case StepSkipped():
            stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.skipped));
            _markStep(step.id, StepStatus.skipped);
            listener?.onStepSkip(step.id, context);
        }
      }

      _progress.value = _progress.value.copyWith(clearCurrentStepId: true);
      listener?.onWorkflowSuccess(context);
      return WorkflowSuccess(context: context, history: stepHistory);

    } catch (e, stack) {
      listener?.onWorkflowFailure(e, stack, context);

      // Trigger compensation (rollback) phase in reverse (LIFO) order for completed steps
      final rollbackErrors = <String, Object>{};
      for (final step in completedSteps.reversed) {
        try {
          listener?.onStepRollbackStart(step.id, context);
          stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.rollbackRunning));
          _markStep(step.id, StepStatus.rollbackRunning, isCurrent: true);
          await step.rollback(context);
          stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.rollbackSuccess));
          _markStep(step.id, StepStatus.rollbackSuccess);
          listener?.onStepRollbackSuccess(step.id, context);
        } catch (rollbackErr) {
          rollbackErrors[step.id] = rollbackErr;
          stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.rollbackFailed, error: rollbackErr));
          _markStep(step.id, StepStatus.rollbackFailed);
          listener?.onStepRollbackFailure(step.id, rollbackErr, context);
        }
      }

      _progress.value = _progress.value.copyWith(clearCurrentStepId: true);

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
