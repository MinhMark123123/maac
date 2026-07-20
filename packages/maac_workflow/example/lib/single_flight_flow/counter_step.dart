import 'package:maac_workflow/maac_workflow.dart';

import 'counter_context.dart';
import 'single_flight_view_model.dart';

class FetchCounterValueStep extends WorkflowStep<CounterContext> {
  final SingleFlightViewModel viewModel;
  FetchCounterValueStep(this.viewModel);

  @override
  String get id => 'fetch_counter_value';

  @override
  String get description => 'Background API: Fetch counter data matching click index';

  @override
  Future<StepResult<void>> execute(CounterContext context, CancellationToken token) async {
    viewModel.logEvent('Click #${context.clickIndex} starting simulated 2-second network request...');

    // Simulate 2-second fetch checking cancellation token frequently
    const int intervals = 10;
    const int delayStep = 200; // 200ms * 10 = 2 seconds
    for (int i = 0; i < intervals; i++) {
      await Future.delayed(const Duration(milliseconds: delayStep));
      if (token.isCancelled) {
        viewModel.logEvent('Click #${context.clickIndex} intercepted cancellation check at interval $i.');
        token.throwIfCancelled();
      }
    }

    context.resultValue = 'Value fetched for click #${context.clickIndex} at ${DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8)}';
    viewModel.logEvent('Click #${context.clickIndex} completed successfully!');
    return const StepSuccess(null);
  }
}
