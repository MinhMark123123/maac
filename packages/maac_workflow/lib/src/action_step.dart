import 'dart:async';

import 'cancellation_token.dart';
import 'result.dart';
import 'step.dart';

typedef StepAction<TContext> = FutureOr<StepResult> Function(TContext context, CancellationToken token);
typedef StepRollbackFn<TContext> = FutureOr<void> Function(TContext context);
typedef StepCanRunFn<TContext> = FutureOr<bool> Function(TContext context);
typedef StepDeactivateFn<TContext> = FutureOr<void> Function(TContext context);

/// A [WorkflowStep] defined by passing its handler functions directly,
/// instead of subclassing [WorkflowStep]. Reach for this for simple steps —
/// a few lines calling an API or writing a field onto the context — where a
/// whole new class would be needless boilerplate. Fully interoperable with
/// every decorator/composite in this package, since it implements the exact
/// same [WorkflowStep] interface a subclass would.
///
/// Usually constructed via the [WorkflowStep.action] factory rather than
/// directly.
class ActionWorkflowStep<TContext> extends WorkflowStep<TContext> {
  @override
  final String id;
  @override
  final String description;
  final StepAction<TContext> action;
  final StepRollbackFn<TContext>? onRollback;
  final StepCanRunFn<TContext>? canRunIf;
  final StepDeactivateFn<TContext>? onDeactivate;

  ActionWorkflowStep({
    required this.id,
    required this.action,
    this.description = '',
    this.onRollback,
    this.canRunIf,
    this.onDeactivate,
  });

  @override
  Future<StepResult> execute(TContext context, CancellationToken token) async => action(context, token);

  @override
  Future<void> rollback(TContext context) async {
    if (onRollback != null) await onRollback!(context);
  }

  @override
  Future<bool> canRun(TContext context) async => canRunIf == null ? true : await canRunIf!(context);

  @override
  Future<void> onDeactivateOrCancel(TContext context) async {
    if (onDeactivate != null) await onDeactivate!(context);
  }
}
