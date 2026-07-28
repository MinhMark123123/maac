import 'action_step.dart';
import 'cancellation_token.dart';
import 'result.dart';

abstract class WorkflowStep<TContext> {
  // Declaring the WorkflowStep.action factory below suppresses the implicit
  // default constructor, so every subclass (ConditionalStep, RetryStepDecorator,
  // InteractiveStep, etc.) needs an explicit generative constructor to extend from.
  WorkflowStep();

  String get id;
  String get description => '';

  /// Executes the core business logic of this step.
  Future<StepResult> execute(TContext context, CancellationToken token);

  /// Performs compensation logic if a subsequent step in the workflow fails.
  /// For example, deleting a file uploaded to the cloud in this step.
  Future<void> rollback(TContext context) async {}

  /// Evaluates whether this step should be executed based on the current context.
  Future<bool> canRun(TContext context) async => true;

  /// Invoked when this step was the active step at the moment its
  /// [CancellationToken] was cancelled. Release resources here (stream
  /// subscriptions, native sessions, open dialogs/pages) that an abandoned
  /// `execute()` Future won't clean up on its own. Default no-op — steps
  /// whose only work is awaiting Futures the token already cancels
  /// transitively (e.g. an HTTP client keyed to the token) don't need to
  /// override this.
  Future<void> onDeactivateOrCancel(TContext context) async {}

  /// Defines a step by passing its handler functions directly, instead of
  /// subclassing [WorkflowStep] — for simple steps that don't need their own
  /// class. See [ActionWorkflowStep].
  factory WorkflowStep.action({
    required String id,
    required StepAction<TContext> execute,
    String description = '',
    StepRollbackFn<TContext>? rollback,
    StepCanRunFn<TContext>? canRun,
    StepDeactivateFn<TContext>? onDeactivateOrCancel,
  }) => ActionWorkflowStep<TContext>(
    id: id,
    action: execute,
    description: description,
    onRollback: rollback,
    canRunIf: canRun,
    onDeactivate: onDeactivateOrCancel,
  );
}
