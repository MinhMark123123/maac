import 'dart:async';
import 'dart:collection';

import 'cancellation_token.dart';
import 'flow_context.dart';
import 'result.dart';
import 'workflow_runner_factory.dart';

/// How [ManagedWorkflowRunner.run] behaves when called again while a
/// previous run is still in flight.
sealed class ConcurrencyStrategy {
  const ConcurrencyStrategy();

  /// Swallow the new call entirely — the in-flight run continues untouched,
  /// and the caller gets back that same run's `Future`.
  const factory ConcurrencyStrategy.ignore() = _IgnoreStrategy;

  /// Cancel the in-flight run, wait for it to fully settle (including its
  /// rollback phase), then start the new run from scratch.
  const factory ConcurrencyStrategy.cancelExisting() = _CancelExistingStrategy;

  /// Queue the new call; it starts once every call ahead of it in the queue
  /// has finished (success, failure, or cancellation).
  const factory ConcurrencyStrategy.enqueue({int? maxQueueLength}) = _EnqueueStrategy;
}

class _IgnoreStrategy extends ConcurrencyStrategy {
  const _IgnoreStrategy();
}

class _CancelExistingStrategy extends ConcurrencyStrategy {
  const _CancelExistingStrategy();
}

class _EnqueueStrategy extends ConcurrencyStrategy {
  final int? maxQueueLength;
  const _EnqueueStrategy({this.maxQueueLength});
}

class _EnqueuedRun<TContext extends FlowContext> {
  final TContext context;
  final CancellationToken token;
  final Completer<WorkflowResult<TContext>> completer = Completer();
  _EnqueuedRun(this.context, this.token);
}

/// Wraps a [WorkflowRunnerFactory] with one of three [ConcurrencyStrategy]
/// behaviors for what happens when [run] is called again while a previous
/// call hasn't finished yet: [ConcurrencyStrategy.ignore],
/// [ConcurrencyStrategy.cancelExisting], or [ConcurrencyStrategy.enqueue].
///
/// For `parallel` (no "one current run" concept — many simultaneous
/// independent runs) use [ParallelWorkflowRunner] instead; for
/// `joinOrCreate` (multiple callers sharing one run, governed by a
/// [JoinCompletionRule]) use [SharedWorkflowRunner] instead — both have a
/// meaningfully different API shape than "call `run`, get a `Future` back."
class ManagedWorkflowRunner<TContext extends FlowContext> {
  final WorkflowRunnerFactory<TContext> createRunner;
  final ConcurrencyStrategy strategy;

  CancellationToken? _activeToken;
  Future<WorkflowResult<TContext>>? _activeFuture;
  final Queue<_EnqueuedRun<TContext>> _queue = Queue();
  bool _draining = false;

  ManagedWorkflowRunner({required this.createRunner, required this.strategy});

  /// Whether a physical run is currently in flight. For
  /// [ConcurrencyStrategy.enqueue], this reflects only the entry currently
  /// executing — not whatever else is still waiting in the queue.
  bool get isRunning => _activeFuture != null;

  /// Starts (or, depending on [strategy], swallows/queues/replaces) a run
  /// with [context]. See [ConcurrencyStrategy] for exactly what happens
  /// when a previous call is still in flight.
  ///
  /// Under [ConcurrencyStrategy.ignore], a swallowed call's own [context] is
  /// never touched — the returned `Future` resolves with whichever run is
  /// actually executing, which may carry a *different* context than the one
  /// passed here.
  Future<WorkflowResult<TContext>> run(TContext context, {CancellationToken? cancellationToken}) {
    switch (strategy) {
      case _IgnoreStrategy():
        return _runIgnore(context, cancellationToken);
      case _CancelExistingStrategy():
        return _runCancelExisting(context, cancellationToken);
      case _EnqueueStrategy(:final maxQueueLength):
        return _runEnqueue(context, cancellationToken, maxQueueLength);
    }
  }

  /// Cancels whatever is currently in flight. Under
  /// [ConcurrencyStrategy.enqueue], also drops every call still waiting in
  /// the queue, completing each with [WorkflowCancelled]. Safe to call when
  /// idle.
  void cancel() {
    _activeToken?.cancel();
    if (strategy is _EnqueueStrategy) {
      for (final entry in _queue) {
        entry.token.cancel();
        entry.completer.complete(WorkflowCancelled(context: entry.context, history: const <WorkflowStepEvent>[]));
      }
      _queue.clear();
    }
  }

  Future<WorkflowResult<TContext>> _runIgnore(TContext context, CancellationToken? cancellationToken) {
    final inFlight = _activeFuture;
    if (inFlight != null) return inFlight;
    return _start(context, cancellationToken);
  }

  Future<WorkflowResult<TContext>> _runCancelExisting(TContext context, CancellationToken? cancellationToken) async {
    final previous = _activeFuture;
    _activeToken?.cancel();
    if (previous != null) await previous;
    return _start(context, cancellationToken);
  }

  Future<WorkflowResult<TContext>> _start(TContext context, CancellationToken? cancellationToken) {
    final runner = createRunner();
    final token = cancellationToken ?? CancellationToken();
    _activeToken = token;
    final future = runner.run(context, cancellationToken: token);
    _activeFuture = future;
    future.whenComplete(() {
      if (identical(_activeFuture, future)) {
        _activeFuture = null;
        _activeToken = null;
      }
    });
    return future;
  }

  Future<WorkflowResult<TContext>> _runEnqueue(TContext context, CancellationToken? cancellationToken, int? maxQueueLength) {
    final entry = _EnqueuedRun<TContext>(context, cancellationToken ?? CancellationToken());
    if (maxQueueLength != null && _queue.length >= maxQueueLength) {
      entry.completer.completeError(StateError('Queue is full (max $maxQueueLength).'));
      return entry.completer.future;
    }
    _queue.add(entry);
    unawaited(_drain());
    return entry.completer.future;
  }

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    while (_queue.isNotEmpty) {
      final entry = _queue.removeFirst();
      if (entry.token.isCancelled) {
        entry.completer.complete(WorkflowCancelled(context: entry.context, history: const <WorkflowStepEvent>[]));
        continue;
      }
      final runner = createRunner();
      _activeToken = entry.token;
      final future = runner.run(entry.context, cancellationToken: entry.token);
      _activeFuture = future;
      final result = await future;
      _activeFuture = null;
      _activeToken = null;
      entry.completer.complete(result);
    }
    _draining = false;
  }
}
