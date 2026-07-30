import 'dart:async';

import 'package:flutter/foundation.dart';

import 'cancellation_token.dart';
import 'flow_context.dart';
import 'interactive_step.dart';
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

  /// Fires after every successful `context.write(...)` made during a run
  /// this listener is attached to. [writerStepId] is the active step's id,
  /// or `null` for a write made with no step active (before the run starts,
  /// after it finishes, or external seeding in between runs).
  void onContextWrite(String key, Object? value, String? writerStepId, TContext context) {}
}

class StepExecutionException implements Exception {
  final WorkflowStep step;
  final Object error;
  final StackTrace stackTrace;

  StepExecutionException({required this.step, required this.error, required this.stackTrace});
}

class WorkflowRunner<TContext extends FlowContext> {
  final List<WorkflowStep<TContext>> steps;
  final WorkflowListener<TContext>? listener;

  final ValueNotifier<WorkflowProgress> _progress = ValueNotifier(const WorkflowProgress());

  /// The step currently executing (forward or rollback), or `null` if no run
  /// is in flight. Only this step may be resolved via [submit]/[fail].
  WorkflowStep<TContext>? _activeStep;

  /// Live snapshot of which step is currently executing and the last known
  /// status of every step reached so far. Reset to all-[StepStatus.pending]
  /// at the start of every [run] call, so a [WorkflowRunner] reused across
  /// multiple runs always reflects the most recent one.
  ValueListenable<WorkflowProgress> get progress => _progress;

  /// The id of the step currently executing (forward or rollback), or `null`
  /// if the workflow hasn't started yet or has already finished. Shorthand
  /// for `progress.value.currentStepId`.
  String? get currentStepId => _progress.value.currentStepId;

  /// The last known status of [stepId], or `null` if it isn't part of
  /// [steps]. Shorthand for `progress.value.statusOf(stepId)`.
  StepStatus? statusOf(String stepId) => _progress.value.statusOf(stepId);

  /// Status of every step declared in [steps], keyed by step id. Shorthand
  /// for `progress.value.stepStatuses`.
  Map<String, StepStatus> get stepStatuses => _progress.value.stepStatuses;

  WorkflowRunner({required this.steps, this.listener});

  void _markStep(WorkflowStep<TContext> step, StepStatus status, {bool isCurrent = false}) {
    final statuses = Map<String, StepStatus>.from(_progress.value.stepStatuses)..[step.id] = status;
    _progress.value = _progress.value.copyWith(
      stepStatuses: statuses,
      currentStepId: isCurrent ? step.id : _progress.value.currentStepId,
    );
  }

  /// Resolves the currently-active step — which must be an [InteractiveStep]
  /// with id [stepId] — with [input], via its `onSubmit`. Throws
  /// [StateError] if no run is in flight, [stepId] isn't the currently
  /// active step, or the active step isn't an [InteractiveStep] — only the
  /// step the engine is actually waiting on may ever be resolved this way.
  void submit(String stepId, [dynamic input]) => _requireActiveInteractive(stepId).resolveSubmit(input);

  /// Resolves the currently-active [InteractiveStep] with id [stepId] as a
  /// failure, via its `onFail`. Same [StateError] conditions as [submit].
  void fail(String stepId, Object error, [StackTrace? stackTrace]) =>
      _requireActiveInteractive(stepId).resolveFail(error, stackTrace ?? StackTrace.current);

  InteractiveStep<TContext, dynamic> _requireActiveInteractive(String stepId) {
    final active = _activeStep;
    if (active == null) {
      throw StateError('No step is currently active; cannot resolve "$stepId".');
    }
    if (active.id != stepId) {
      throw StateError('Step "$stepId" is not the currently active step (active step is "${active.id}").');
    }
    if (active is! InteractiveStep<TContext, dynamic>) {
      throw StateError('Step "$stepId" is active but is not an InteractiveStep.');
    }
    return active;
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

    // Invoked synchronously the instant `token.cancel()` fires, regardless
    // of whether the active step's `execute()` Future has resolved yet —
    // this is what makes cleanup "immediate" per the cancellation
    // requirements, without needing to force-interrupt the loop itself.
    token.onCancel(() {
      final step = _activeStep;
      if (step != null) unawaited(step.onDeactivateOrCancel(context));
    });

    _progress.value = WorkflowProgress(
      stepStatuses: {for (final step in steps) step.id: StepStatus.pending},
    );

    final activeListener = listener;
    if (activeListener != null) {
      context.setWriteInterceptor((key, value, writerStepId) => activeListener.onContextWrite(key, value, writerStepId, context));
    }

    listener?.onWorkflowStart(context);

    try {
      for (final step in steps) {
        token.throwIfCancelled();

        // 1. Evaluate if the step should execute
        final canExecute = await step.canRun(context);
        if (!canExecute) {
          stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.skipped));
          _markStep(step, StepStatus.skipped);
          listener?.onStepSkip(step.id, context);
          continue;
        }

        // 2. Trigger step start lifecycle events
        listener?.onStepStart(step.id, context);
        stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.running));
        _markStep(step, step is InteractiveStep ? StepStatus.awaitingInput : StepStatus.running, isCurrent: true);
        _activeStep = step;
        context.setActiveStepId(step.id);

        // 3. Execute core step logic
        final result = await step.execute(context, token);
        _activeStep = null;
        context.setActiveStepId(null);
        token.throwIfCancelled();

        // 4. Analyze execution result
        switch (result) {
          case StepSuccess():
            completedSteps.add(step);
            stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.success));
            _markStep(step, StepStatus.success);
            listener?.onStepSuccess(step.id, context);

          case StepFailure(:final error, :final stackTrace):
            stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.failed, error: error));
            _markStep(step, StepStatus.failed);
            listener?.onStepFailure(step.id, error, stackTrace, context);
            throw StepExecutionException(step: step, error: error, stackTrace: stackTrace);

          case StepSkipped():
            stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.skipped));
            _markStep(step, StepStatus.skipped);
            listener?.onStepSkip(step.id, context);
        }
      }

      _progress.value = _progress.value.copyWith(clearCurrentStepId: true);
      listener?.onWorkflowSuccess(context);
      return WorkflowSuccess(context: context, history: stepHistory);

    } catch (e, stack) {
      _activeStep = null;
      context.setActiveStepId(null);
      listener?.onWorkflowFailure(e, stack, context);

      // Trigger compensation (rollback) phase in reverse (LIFO) order for completed steps
      final rollbackErrors = <String, Object>{};
      for (final step in completedSteps.reversed) {
        try {
          listener?.onStepRollbackStart(step.id, context);
          stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.rollbackRunning));
          _markStep(step, StepStatus.rollbackRunning, isCurrent: true);
          context.setActiveStepId(step.id);
          await step.rollback(context);
          stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.rollbackSuccess));
          _markStep(step, StepStatus.rollbackSuccess);
          listener?.onStepRollbackSuccess(step.id, context);
        } catch (rollbackErr) {
          rollbackErrors[step.id] = rollbackErr;
          stepHistory.add(WorkflowStepEvent(stepId: step.id, status: StepStatus.rollbackFailed, error: rollbackErr));
          _markStep(step, StepStatus.rollbackFailed);
          listener?.onStepRollbackFailure(step.id, rollbackErr, context);
        } finally {
          context.setActiveStepId(null);
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
    } finally {
      context.setWriteInterceptor(null);
    }
  }
}
