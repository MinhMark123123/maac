import 'dart:async';

import '../cancellation_token.dart';
import '../result.dart';
import '../step.dart';

/// Wraps [step] so that it fails with a [StepFailure] holding a [TimeoutException]
/// if it doesn't complete within [timeout].
///
/// The wrapped step receives its own, internal [CancellationToken] instead of the
/// workflow's token directly: cancellation from the parent workflow still propagates
/// down to it, but timing out only cancels this inner token (letting [step] stop any
/// in-flight work, e.g. a stream subscription) without cancelling the whole workflow.
/// This keeps a timeout a regular, retryable/rollback-able [StepFailure] rather than
/// turning the entire workflow into [WorkflowCancelled].
class TimeoutStepDecorator<TContext> extends WorkflowStep<TContext> {
  final WorkflowStep<TContext> step;
  final Duration timeout;

  TimeoutStepDecorator({required this.step, required this.timeout});

  @override
  String get id => '${step.id}_timeout';

  @override
  Future<bool> canRun(TContext context) => step.canRun(context);

  @override
  Future<StepResult> execute(TContext context, CancellationToken token) async {
    final innerToken = CancellationToken();
    token.onCancel(innerToken.cancel);

    try {
      return await step.execute(context, innerToken).timeout(
        timeout,
        onTimeout: () {
          innerToken.cancel();
          return StepFailure(
            TimeoutException('Step "${step.id}" timed out after $timeout'),
            StackTrace.current,
          );
        },
      );
    } catch (e, stack) {
      return StepFailure(e, stack);
    }
  }

  @override
  Future<void> rollback(TContext context) => step.rollback(context);
}
