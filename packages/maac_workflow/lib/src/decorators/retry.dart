import '../cancellation_token.dart';
import '../result.dart';
import '../step.dart';

class RetryStepDecorator<TContext> extends WorkflowStep<TContext> {
  final WorkflowStep<TContext> step;
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffFactor;
  final bool Function(Object error)? retryIf;

  RetryStepDecorator({
    required this.step,
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffFactor = 2.0,
    this.retryIf,
  });

  @override
  String get id => '${step.id}_retry';

  @override
  Future<StepResult> execute(TContext context, CancellationToken token) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      attempt++;
      token.throwIfCancelled();
      try {
        final result = await step.execute(context, token);
        if (result is StepSuccess || result is StepSkipped) {
          return result;
        }
        final failure = result as StepFailure;
        if (attempt >= maxAttempts || (retryIf != null && !retryIf!(failure.error))) {
          return failure;
        }
      } catch (e, stack) {
        if (attempt >= maxAttempts || (retryIf != null && !retryIf!(e))) {
          return StepFailure(e, stack);
        }
      }

      await Future.delayed(delay);
      delay = delay * backoffFactor;
    }
  }

  @override
  Future<void> rollback(TContext context) => step.rollback(context);
}
