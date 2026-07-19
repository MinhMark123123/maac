import 'cancellation_token.dart';
import 'result.dart';
import 'runner.dart';

/// Guarantees at most one execution of [runner] is ever active at a time.
///
/// This is the general form of a pattern that shows up under many names depending
/// on context — "single active subscription" for a stream watched by a screen,
/// "only one loading indicator" for a global spinner, "search-as-you-type" for
/// debounced lookups: whatever is currently running must be cancelled before the
/// next one is allowed to start.
///
/// Each call to [run] cancels the previous in-flight [CancellationToken] (if any)
/// and starts [runner] with a brand new one. [cancel] stops whatever is currently
/// running without starting anything new — call it from lifecycle hooks such as
/// `onPause`/`onDispose` to stop work while a screen isn't visible.
class SingleFlightWorkflowRunner<TContext> {
  final WorkflowRunner<TContext> runner;
  CancellationToken? _activeToken;

  SingleFlightWorkflowRunner(this.runner);

  /// Whether a run is currently in flight.
  bool get isRunning => _activeToken != null && !_activeToken!.isCancelled;

  /// Cancels any run currently in flight, then starts a new one.
  Future<WorkflowResult<TContext>> run(TContext context) {
    cancel();
    final token = CancellationToken();
    _activeToken = token;
    return runner.run(context, cancellationToken: token);
  }

  /// Cancels the currently active run, if any. Safe to call when idle.
  void cancel() {
    _activeToken?.cancel();
    _activeToken = null;
  }
}
