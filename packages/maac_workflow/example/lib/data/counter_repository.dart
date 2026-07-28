import 'package:maac_workflow/maac_workflow.dart';

import 'simulated_delay.dart';

/// Simulates the "fetch counter value" backend call behind the
/// single-flight demo — a 2-second network request, checking [token]
/// every 200ms so a superseded click is cancelled promptly instead of
/// running to completion in the background.
class CounterRepository {
  Future<String> fetchValue(int clickIndex, CancellationToken token) async {
    await simulateCancellableDelay(const Duration(seconds: 2), token);
    final timestamp = DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8);
    return 'Value fetched for click #$clickIndex at $timestamp';
  }
}
