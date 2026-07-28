import 'package:maac_workflow/maac_workflow.dart';

/// Shared state passed to a single simulated "fetch counter value" run.
class CounterContext extends FlowContext {
  final int clickIndex;
  String? resultValue;

  CounterContext(this.clickIndex);
}

/// Visual status of one tracked click for the tracker list UI.
enum ExecutionStatus { active, cancelled, completed }

class ExecutionTracker {
  final int clickIndex;
  final DateTime timestamp;
  ExecutionStatus status;
  String? result;

  ExecutionTracker(this.clickIndex)
      : timestamp = DateTime.now(),
        status = ExecutionStatus.active;
}
