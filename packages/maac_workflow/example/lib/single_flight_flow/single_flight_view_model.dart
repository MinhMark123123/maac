import 'package:maac_mvvm/maac_mvvm.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_workflow/maac_workflow.dart';
import 'package:maac_workflow_example/data/ticker_repository.dart';

import '../common/logging_view_model.dart';
import '../common/logging_workflow_listener.dart';
import 'counter_context.dart';

part 'single_flight_view_model.g.dart';

@BindableViewModel()
class SingleFlightViewModel extends LoggingViewModel {
  @Bind()
  late final _trackers = <ExecutionTracker>[].mtd(this);

  int _clickCount = 0;

  final _tickerRepository = TickerRepository();

  late final _singleFlightRunner = ManagedWorkflowRunner<SimpleStreamContext>(
    createRunner: () => WorkflowRunner<SimpleStreamContext>(
      steps: [
        WorkflowStep.sustained(
          id: 'watch_ticks',
          start: (context, fail) {
            context.subscription = _tickerRepository.watchTicks().listen((tick) {
              logEvent('Click #${context.clickIndex} tick #$tick');
              _updateTrackerResult(context.clickIndex, 'Tick #$tick');
            }, onError: fail);
            logEvent('Click #${context.clickIndex} now listening for ticks.');
          },
          stop: (context) {
            logEvent('Click #${context.clickIndex} stream stopped.');
            context.subscription?.cancel();
          },
        ),
      ],
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

    // Run in SingleFlight mode: starting a new click cancels the previous
    // click's still-ticking subscription before this one starts.
    await _singleFlightRunner.run(SimpleStreamContext(index));
    _singleFlightRunner.cancel();
  }

  void _updateTrackerResult(int index, String result) {
    final list = List<ExecutionTracker>.from(_trackers.data);
    final idx = list.indexWhere((t) => t.clickIndex == index);
    if (idx != -1) {
      list[idx].result = result;
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
    _singleFlightRunner.cancel();
    super.onDispose();
  }
}

/// Logs every lifecycle event via [LoggingWorkflowListener], overriding the
/// workflow-level ones to include the click index, and to mark this click's
/// UI tracker as cancelled when a run is superseded by a newer click.
class SingleFlightListener extends LoggingWorkflowListener<SimpleStreamContext> {
  final SingleFlightViewModel viewModel;

  SingleFlightListener(this.viewModel) : super(prefix: '[SingleFlight]', logEvent: viewModel.logEvent);

  @override
  void onWorkflowStart(SimpleStreamContext context) => logEvent('[SingleFlight] Run starting for click #${context.clickIndex}...');

  @override
  void onWorkflowFailure(Object error, StackTrace stackTrace, SimpleStreamContext context) {
    if (error is WorkflowCancelledException) {
      logEvent('[SingleFlight] Run cancelled/aborted for click #${context.clickIndex}.');
      viewModel._markTrackerAsCancelled(context.clickIndex);
    } else {
      logEvent('[SingleFlight] Run failed for click #${context.clickIndex}: $error');
    }
  }
}
