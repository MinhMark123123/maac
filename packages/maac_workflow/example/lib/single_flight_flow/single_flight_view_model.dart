import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_workflow/maac_workflow.dart';

import 'counter_context.dart';
import 'counter_step.dart';

part 'single_flight_view_model.g.dart';

@BindableViewModel()
class SingleFlightViewModel extends ViewModel {
  @Bind()
  late final _workflowHistory = <String>[].mtd(this);

  @Bind()
  late final _trackers = <ExecutionTracker>[].mtd(this);

  int _clickCount = 0;

  late final _singleFlightRunner = SingleFlightWorkflowRunner<CounterContext>(
    WorkflowRunner<CounterContext>(
      steps: [FetchCounterValueStep(this)],
      listener: SingleFlightListener(this),
    ),
  );

  void logEvent(String msg) {
    final list = List<String>.from(_workflowHistory.data);
    list.add('[${DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8)}] $msg');
    _workflowHistory.postValue(list);
  }

  void clearLogs() {
    _workflowHistory.postValue([]);
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

  // --- WorkflowListener callbacks (triggered by SingleFlightListener) ---
  void onWorkflowStart(CounterContext context) {
    logEvent('[SingleFlight] Run starting for click #${context.clickIndex}...');
  }

  void onWorkflowSuccess(CounterContext context) {
    logEvent('[SingleFlight] Run success for click #${context.clickIndex}!');
  }

  void onWorkflowFailure(Object error, StackTrace stackTrace, CounterContext context) {
    if (error is WorkflowCancelledException) {
      logEvent('[SingleFlight] Run cancelled/aborted for click #${context.clickIndex}.');
      // Update UI tracker as cancelled
      _markTrackerAsCancelled(context.clickIndex);
    } else {
      logEvent('[SingleFlight] Run failed for click #${context.clickIndex}: $error');
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

/// Adapts [WorkflowListener] callbacks to plain methods on [SingleFlightViewModel]
/// so the view model doesn't need to implement the full listener interface.
class SingleFlightListener extends WorkflowListener<CounterContext> {
  final SingleFlightViewModel viewModel;
  SingleFlightListener(this.viewModel);

  @override
  void onWorkflowStart(CounterContext context) => viewModel.onWorkflowStart(context);

  @override
  void onWorkflowSuccess(CounterContext context) => viewModel.onWorkflowSuccess(context);

  @override
  void onWorkflowFailure(Object error, StackTrace stackTrace, CounterContext context) =>
      viewModel.onWorkflowFailure(error, stackTrace, context);
}
