import 'dart:async';

import 'action_step.dart';
import 'cancellation_token.dart';
import 'result.dart';
import 'step.dart';

typedef SustainedStepStart<TContext> = FutureOr<void> Function(TContext context, void Function(Object error, [StackTrace? stackTrace]) fail);
typedef SustainedStepStop<TContext> = FutureOr<void> Function(TContext context);

/// A [WorkflowStep] for work with no natural completion of its own — a live
/// stream subscription, an open connection, a polling loop, anything that's
/// simply "started" and then just keeps running. Unlike an ordinary step,
/// `execute()` deliberately never resolves on its own once [start] returns —
/// it stays pending until this step is cancelled or deactivated (e.g. by a
/// superseding [ManagedWorkflowRunner.cancelExisting] run), at which point
/// [stop] tears the work down.
///
/// Neither [start] nor [stop] ever see a [CancellationToken]: cancellation
/// is exactly what ends this step, so there's nothing left for the callback
/// to poll — [stop] *is* the reaction to it. The only thing [start] can
/// actively report is failure, via the `fail` callback it's given (e.g. a
/// stream's `onError`) — there's no matching "succeed now", since a step
/// with no natural completion has no natural "succeeded now" moment; only
/// cancellation ends it successfully.
///
/// Usually constructed via the [WorkflowStep.sustained] factory rather than
/// directly.
class SustainedWorkflowStep<TContext> extends WorkflowStep<TContext> {
  @override
  final String id;
  @override
  final String description;
  final SustainedStepStart<TContext> start;
  final SustainedStepStop<TContext> stop;
  final StepCanRunFn<TContext>? canRunIf;

  SustainedWorkflowStep({required this.id, required this.start, required this.stop, this.description = '', this.canRunIf});

  @override
  Future<StepResult> execute(TContext context, CancellationToken token) async {
    final completer = Completer<StepResult>();

    token.onCancel(() {
      if (!completer.isCompleted) completer.complete(const StepSuccess());
    });

    void fail(Object error, [StackTrace? stackTrace]) {
      if (completer.isCompleted) return;
      // Unlike cancellation, a self-reported failure never reaches
      // `onDeactivateOrCancel` (the engine only calls that in reaction to
      // its own token being cancelled) — so this is the only place `stop`
      // ever runs for a step that fails on its own. Fire-and-forget, same
      // as the engine's own handling of `onDeactivateOrCancel` elsewhere.
      unawaited(Future.sync(() => stop(context)));
      completer.complete(StepFailure(error, stackTrace ?? StackTrace.current));
    }

    try {
      await start(context, fail);
    } catch (e, stack) {
      fail(e, stack);
    }

    return completer.future;
  }

  @override
  Future<void> onDeactivateOrCancel(TContext context) async => stop(context);

  @override
  Future<bool> canRun(TContext context) async => canRunIf == null ? true : await canRunIf!(context);
}
