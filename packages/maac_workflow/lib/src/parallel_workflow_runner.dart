import 'package:flutter/foundation.dart';

import 'cancellation_token.dart';
import 'flow_context.dart';
import 'progress.dart';
import 'result.dart';
import 'runner.dart';
import 'workflow_runner_factory.dart';

/// The "parallel" concurrency strategy: every call to [run] spins up a
/// fully independent [WorkflowRunner] (via [createRunner]) with its own
/// isolated `FlowContext`, running concurrently with any other in-flight
/// calls rather than cancelling or queuing them. See [ManagedWorkflowRunner]
/// for the "one current run" strategies (`ignore`/`cancelExisting`/`enqueue`)
/// and [SharedWorkflowRunner] for `joinOrCreate`.
class ParallelWorkflowRunner<TContext extends FlowContext> {
  final WorkflowRunnerFactory<TContext> createRunner;

  final List<ParallelRunHandle<TContext>> _active = [];

  ParallelWorkflowRunner({required this.createRunner});

  /// Snapshot of every run currently in flight. A handle is removed the
  /// instant its own [ParallelRunHandle.result] settles.
  List<ParallelRunHandle<TContext>> get activeRuns => List.unmodifiable(_active);

  /// Starts a brand new, isolated run and returns a handle to it
  /// immediately (before the run itself has necessarily progressed at all).
  ParallelRunHandle<TContext> run(TContext context, {CancellationToken? cancellationToken}) {
    final runner = createRunner();
    final token = cancellationToken ?? CancellationToken();
    late final ParallelRunHandle<TContext> handle;
    final result = runner.run(context, cancellationToken: token);
    handle = ParallelRunHandle<TContext>._(runner: runner, context: context, cancellationToken: token, result: result);
    _active.add(handle);
    result.whenComplete(() => _active.remove(handle));
    return handle;
  }
}

/// A single invocation started by [ParallelWorkflowRunner.run] — its own
/// isolated [runner]/[context], not shared with any other concurrent run.
class ParallelRunHandle<TContext extends FlowContext> {
  final WorkflowRunner<TContext> runner;
  final TContext context;
  final CancellationToken cancellationToken;
  final Future<WorkflowResult<TContext>> result;

  /// This invocation's own progress — not aggregated with any other
  /// concurrent run, since each handle already carries a direct reference.
  ValueListenable<WorkflowProgress> get progress => runner.progress;

  void cancel() => cancellationToken.cancel();

  ParallelRunHandle._({
    required this.runner,
    required this.context,
    required this.cancellationToken,
    required this.result,
  });
}
