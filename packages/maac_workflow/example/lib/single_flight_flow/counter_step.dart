import 'package:maac_workflow/maac_workflow.dart';

import '../common/callbacks.dart';
import '../data/counter_repository.dart';
import 'counter_context.dart';

class FetchCounterValueStep extends WorkflowStep<CounterContext> {
  final LogEvent logEvent;
  final CounterRepository counterRepository;
  FetchCounterValueStep({required this.logEvent, required this.counterRepository});

  @override
  String get id => 'fetch_counter_value';

  @override
  String get description => 'Background API: Fetch counter data matching click index';

  @override
  Future<StepResult> execute(CounterContext context, CancellationToken token) async {
    logEvent('Click #${context.clickIndex} starting simulated 2-second network request...');

    context.resultValue = await counterRepository.fetchValue(context.clickIndex, token);

    logEvent('Click #${context.clickIndex} completed successfully!');
    return const StepSuccess();
  }
}
