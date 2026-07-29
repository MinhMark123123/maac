/// Simulates a live backend feed that pushes a new value once per second —
/// e.g. a polling endpoint or websocket — instead of resolving once like the
/// other repositories in `data/`. Meant for demoing how a `WorkflowStep` can
/// stay open against an ongoing `Stream` rather than a one-shot `Future`.
class TickerRepository {
  /// Emits an incrementing tick count, starting at 1, once every second.
  /// Runs indefinitely — it never completes on its own, so the listener is
  /// responsible for tearing down its subscription when done (e.g. wiring
  /// `CancellationToken.onCancel` to `subscription.cancel()` inside a
  /// `WorkflowStep`, so a cancelled workflow doesn't leave this ticking in
  /// the background).
  Stream<int> watchTicks() => Stream.periodic(const Duration(seconds: 1), (i) => i + 1);
}
