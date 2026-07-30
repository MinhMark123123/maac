import 'package:maac_workflow/maac_workflow.dart';

/// A [WorkflowListener] that logs every lifecycle event through a callback
/// supplied at construction, so a flow-specific listener only needs to
/// override the handful of methods it wants to attach extra behavior to —
/// not re-implement forwarding for every single method just to reach a
/// ViewModel's `logEvent`.
class LoggingWorkflowListener<TContext> extends WorkflowListener<TContext> {
  final String prefix;
  final void Function(String message) logEvent;

  LoggingWorkflowListener({required this.prefix, required this.logEvent});

  @override
  void onWorkflowStart(TContext context) => logEvent('$prefix Workflow Start');

  @override
  void onStepStart(String stepId, TContext context) => logEvent('$prefix Step Start: $stepId');

  @override
  void onStepSuccess(String stepId, TContext context) => logEvent('$prefix Step Success: $stepId');

  @override
  void onStepSkip(String stepId, TContext context) => logEvent('$prefix Step Skip: $stepId');

  @override
  void onStepFailure(String stepId, Object error, StackTrace stackTrace, TContext context) =>
      logEvent('$prefix Step Failure: $stepId. Error: $error');

  @override
  void onStepRollbackStart(String stepId, TContext context) => logEvent('$prefix Rollback Start: $stepId');

  @override
  void onStepRollbackSuccess(String stepId, TContext context) => logEvent('$prefix Rollback Success: $stepId');

  @override
  void onStepRollbackFailure(String stepId, Object error, TContext context) =>
      logEvent('$prefix Rollback Failure: $stepId. Error: $error');

  @override
  void onWorkflowSuccess(TContext context) => logEvent('$prefix Workflow Finished: Success');

  @override
  void onWorkflowFailure(Object error, StackTrace stackTrace, TContext context) =>
      logEvent('$prefix Workflow Finished: Failure');
}
