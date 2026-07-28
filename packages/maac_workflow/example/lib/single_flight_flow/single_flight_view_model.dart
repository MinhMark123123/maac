import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_workflow/maac_workflow.dart';

import '../common/logging_view_model.dart';
import '../common/logging_workflow_listener.dart';
import '../data/counter_repository.dart';
import 'counter_context.dart';
import 'counter_step.dart';

part 'single_flight_view_model.g.dart';

@BindableViewModel()
class SingleFlightViewModel extends LoggingViewModel {
  @Bind()
  late final _trackers = <ExecutionTracker>[].mtd(this);

  int _clickCount = 0;

  final counterRepository = CounterRepository();

  late final _singleFlightRunner = ManagedWorkflowRunner<CounterContext>(
    createRunner: () => WorkflowRunner<CounterContext>(
      steps: [FetchCounterValueStep(logEvent: logEvent, counterRepository: counterRepository)],
      listener: SingleFlightListener(this),
    ),
    strategy: const ConcurrencyStrategy.cancelExisting(),
  );

  @override
  void clearLogs() {
    super.clearLogs();
    _trackers.postValue([]);
    _clickCount = 0;
  }

  void triggerClick() async {
    _clickCount++;
    final index = _clickCount;
    logEvent('--- User clicked: #$index ---');

    // Add tracker for UI
    final tracker = ExecutionTracker(index);
    final currentTrackers = List<ExecutionTracker>.from(_trackers.data);
    currentTrackers.insert(0, tracker); // Newest on top
    _trackers.postValue(currentTrackers);

    // Run in SingleFlight mode
    final context = CounterContext(index);
    final result = await _singleFlightRunner.run(context);

    // Update tracker status based on result
    _updateTracker(index, result);
  }

  void _updateTracker(int index, WorkflowResult<CounterContext> result) {
    final list = List<ExecutionTracker>.from(_trackers.data);
    final idx = list.indexWhere((t) => t.clickIndex == index);
    if (idx != -1) {
      final tracker = list[idx];
      switch (result) {
        case WorkflowSuccess():
          tracker.status = ExecutionStatus.completed;
          tracker.result = result.context.resultValue;
          break;
        case WorkflowFailure(:final error):
          tracker.status = ExecutionStatus.cancelled; // Any step failure under cancellation resolves here
          tracker.result = 'Failed: $error';
          break;
        case WorkflowCancelled():
          tracker.status = ExecutionStatus.cancelled;
          tracker.result = 'Cancelled by SingleFlight runner';
          break;
      }
      _trackers.postValue(list);
    }
  }

  void _markTrackerAsCancelled(int index) {
    final list = List<ExecutionTracker>.from(_trackers.data);
    final idx = list.indexWhere((t) => t.clickIndex == index);
    if (idx != -1) {
      list[idx].status = ExecutionStatus.cancelled;
      list[idx].result = 'Cancelled by SingleFlight runner';
      _trackers.postValue(list);
    }
  }

  @override
  void onDispose() {
    clearLogs();
    super.onDispose();
  }
}

/// Logs every lifecycle event via [LoggingWorkflowListener], overriding the
/// workflow-level ones to include the click index, and to mark this click's
/// UI tracker as cancelled when a run is superseded by a newer click.
class SingleFlightListener extends LoggingWorkflowListener<CounterContext> {
  final SingleFlightViewModel viewModel;

  SingleFlightListener(this.viewModel) : super(prefix: '[SingleFlight]', logEvent: viewModel.logEvent);

  @override
  void onWorkflowStart(CounterContext context) => logEvent('[SingleFlight] Run starting for click #${context.clickIndex}...');

  @override
  void onWorkflowSuccess(CounterContext context) => logEvent('[SingleFlight] Run success for click #${context.clickIndex}!');

  @override
  void onWorkflowFailure(Object error, StackTrace stackTrace, CounterContext context) {
    if (error is WorkflowCancelledException) {
      logEvent('[SingleFlight] Run cancelled/aborted for click #${context.clickIndex}.');
      viewModel._markTrackerAsCancelled(context.clickIndex);
    } else {
      logEvent('[SingleFlight] Run failed for click #${context.clickIndex}: $error');
    }
  }
}
