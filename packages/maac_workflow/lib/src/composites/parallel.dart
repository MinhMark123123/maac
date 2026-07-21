import '../cancellation_token.dart';
import '../result.dart';
import '../step.dart';

class ParallelStep<TContext> extends WorkflowStep<TContext> {
  @override
  final String id;
  final List<WorkflowStep<TContext>> subSteps;

  ParallelStep({required this.id, required this.subSteps});

  @override
  Future<StepResult> execute(TContext context, CancellationToken token) async {
    try {
      final futures = subSteps.map((s) async {
        final canRun = await s.canRun(context);
        if (!canRun) return const StepSkipped();
        return s.execute(context, token);
      });

      final results = await Future.wait(futures);

      for (final res in results) {
        if (res is StepFailure) {
          return StepFailure(res.error, res.stackTrace);
        }
      }
      return const StepSuccess();
    } catch (e, stack) {
      return StepFailure(e, stack);
    }
  }

  @override
  Future<void> rollback(TContext context) async {
    await Future.wait(subSteps.map((s) => s.rollback(context)));
  }
}
