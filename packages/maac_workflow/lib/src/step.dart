import 'cancellation_token.dart';
import 'result.dart';

abstract class WorkflowStep<TContext> {
  String get id;
  String get description => '';

  /// Executes the core business logic of this step.
  Future<StepResult<void>> execute(TContext context, CancellationToken token);

  /// Performs compensation logic if a subsequent step in the workflow fails.
  /// For example, deleting a file uploaded to the cloud in this step.
  Future<void> rollback(TContext context) async {}

  /// Evaluates whether this step should be executed based on the current context.
  Future<bool> canRun(TContext context) async => true;
}
