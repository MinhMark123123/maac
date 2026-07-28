import 'dart:async';

import 'package:meta/meta.dart';

import 'cancellation_token.dart';
import 'result.dart';
import 'step.dart';

/// A [WorkflowStep] that pauses and waits for an external signal — typically
/// a UI form submission — instead of resolving on its own.
///
/// The engine owns creating, resolving, and discarding the internal
/// [Completer] this needs; step authors never touch one directly. Trigger
/// side effects (e.g. navigation) once this step becomes active from
/// [onActivate], then resume the workflow from outside by calling
/// `WorkflowRunner.submit(id, input)` (routed to [onSubmit]) or
/// `WorkflowRunner.fail(id, error)` (routed to [onFail]).
abstract class InteractiveStep<TContext, TInput> extends WorkflowStep<TContext> {
  Completer<StepResult>? _pending;
  TContext? _activeContext;
  CancellationToken? _activeToken;

  /// Whether this step is currently paused, awaiting `submit`/`fail`.
  bool get isAwaitingInput => _pending != null && !_pending!.isCompleted;

  @override
  Future<StepResult> execute(TContext context, CancellationToken token) async {
    final completer = Completer<StepResult>();
    _pending = completer;
    _activeContext = context;
    _activeToken = token;
    // Engine-owned cleanup: resolves this step the instant the token is
    // cancelled, so a paused step never leaves execute()'s Future hanging.
    token.onCancel(() {
      if (!completer.isCompleted) {
        completer.complete(StepFailure(WorkflowCancelledException(), StackTrace.current));
      }
    });
    await onActivate(context, token);
    return completer.future;
  }

  /// Called once, as this step becomes active, before the engine starts
  /// waiting — trigger navigation / arm a listener here. Default no-op.
  FutureOr<void> onActivate(TContext context, CancellationToken token) {}

  /// Called when `WorkflowRunner.submit(id, input)` resolves this step.
  /// Validate/apply [input] onto [context] and return the outcome.
  FutureOr<StepResult> onSubmit(TContext context, TInput input, CancellationToken token);

  /// Called when `WorkflowRunner.fail(id, error)` resolves this step.
  /// Default: a plain [StepFailure].
  FutureOr<StepResult> onFail(TContext context, Object error, StackTrace stackTrace, CancellationToken token) =>
      StepFailure(error, stackTrace);

  /// Called by `WorkflowRunner.submit` — not part of the public API contract
  /// for application code.
  @internal
  void resolveSubmit(dynamic input) {
    final completer = _pending;
    final context = _activeContext;
    final token = _activeToken;
    if (completer == null || completer.isCompleted || context == null || token == null) {
      throw StateError('Step "$id" is not currently awaiting input.');
    }
    // Claimed synchronously, before scheduling the (possibly async) onSubmit
    // call — otherwise a second submit()/fail() racing in before the first
    // one's microtask runs would pass this same guard and double-complete
    // `completer`, instead of cleanly throwing StateError.
    _pending = null;
    Future.sync(() => onSubmit(context, input as TInput, token)).then(
      completer.complete,
      onError: (Object e, StackTrace st) => completer.complete(StepFailure(e, st)),
    );
  }

  /// Called by `WorkflowRunner.fail` — not part of the public API contract
  /// for application code.
  @internal
  void resolveFail(Object error, StackTrace stackTrace) {
    final completer = _pending;
    final context = _activeContext;
    final token = _activeToken;
    if (completer == null || completer.isCompleted || context == null || token == null) {
      throw StateError('Step "$id" is not currently awaiting input.');
    }
    _pending = null;
    Future.sync(() => onFail(context, error, stackTrace, token)).then(
      completer.complete,
      onError: (Object e, StackTrace st) => completer.complete(StepFailure(e, st)),
    );
  }
}
