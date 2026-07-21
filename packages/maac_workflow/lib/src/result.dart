/// Represents the result of an individual step execution.
///
/// Steps don't return typed values here — `rollback(context)` only ever
/// receives the shared `TContext`, so any data a step produces has to live on
/// `context` anyway for rollback to see it. A step reports success/failure/skip
/// through this type; it carries its output by writing typed fields onto
/// `context`, not through a generic result value.
sealed class StepResult {
  const StepResult();
}

class StepSuccess extends StepResult {
  const StepSuccess();
}

class StepFailure extends StepResult {
  final Object error;
  final StackTrace stackTrace;
  const StepFailure(this.error, [this.stackTrace = StackTrace.empty]);
}

class StepSkipped extends StepResult {
  const StepSkipped();
}

/// Represents the overall outcome of a workflow execution.
sealed class WorkflowResult<TContext> {
  final TContext context;
  final List<WorkflowStepEvent> history;

  const WorkflowResult({required this.context, required this.history});
}

class WorkflowSuccess<TContext> extends WorkflowResult<TContext> {
  const WorkflowSuccess({required super.context, required super.history});
}

class WorkflowFailure<TContext> extends WorkflowResult<TContext> {
  final String failedStepId;
  final Object error;
  final StackTrace stackTrace;
  /// Errors that occurred during the rollback (compensation) phase of completed steps.
  final Map<String, Object> rollbackErrors;

  const WorkflowFailure({
    required super.context,
    required super.history,
    required this.failedStepId,
    required this.error,
    required this.stackTrace,
    this.rollbackErrors = const {},
  });
}

class WorkflowCancelled<TContext> extends WorkflowResult<TContext> {
  const WorkflowCancelled({required super.context, required super.history});
}

/// The execution status of a workflow step, useful for audit logging, analytics,
/// and driving a live step indicator UI via [WorkflowRunner.progress].
enum StepStatus {
  /// The step hasn't been reached yet.
  pending,
  running,
  success,
  failed,
  skipped,
  rollbackRunning,
  rollbackSuccess,
  rollbackFailed,
}

class WorkflowStepEvent {
  final String stepId;
  final StepStatus status;
  final Object? error;
  final DateTime timestamp;

  WorkflowStepEvent({
    required this.stepId,
    required this.status,
    this.error,
  }) : timestamp = DateTime.now();
}
