import '../cancellation_token.dart';
import '../result.dart';
import '../step.dart';

class ConditionalStep<TContext> extends WorkflowStep<TContext> {
  @override
  final String id;
  final bool Function(TContext context) condition;
  final WorkflowStep<TContext> step;

  ConditionalStep({
    required this.id,
    required this.condition,
    required this.step,
  });

  @override
  Future<bool> canRun(TContext context) async {
    return condition(context);
  }

  @override
  Future<StepResult<void>> execute(TContext context, CancellationToken token) {
    return step.execute(context, token);
  }

  @override
  Future<void> rollback(TContext context) {
    return step.rollback(context);
  }
}
