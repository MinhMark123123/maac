import 'package:maac_workflow/maac_workflow.dart';

/// Awaits [duration] in small chunks, checking [token] after each one — so a
/// caller cancelling mid-wait notices within [checkInterval], instead of
/// only after the full [duration] elapses. Used by repository methods that
/// simulate a long-running network call a user might reasonably cancel.
Future<void> simulateCancellableDelay(
  Duration duration,
  CancellationToken token, {
  Duration checkInterval = const Duration(milliseconds: 200),
}) async {
  var remaining = duration;
  while (remaining > Duration.zero) {
    final chunk = remaining < checkInterval ? remaining : checkInterval;
    await Future.delayed(chunk);
    token.throwIfCancelled();
    remaining -= chunk;
  }
}
